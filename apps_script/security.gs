//=====================================================================
//  SECURITY LAYER
//=====================================================================
//
//  The problem this fixes:
//
//  1. The coach code sat in the app's source, in a public repository.
//     Anyone could read it and sign in as coach.
//  2. The web app answered anybody. No sign in was needed to pull the
//     whole player list, the fees, or the coach salary - a plain URL in
//     a browser was enough.
//  3. Signing in as a player only needed an email address, and the
//     phone downloaded EVERY player's records and hid the other rows
//     on the device. Hidden is not the same as not sent.
//
//  How it works after this:
//
//  Signing in happens here, on the server. It hands back a token that
//  is signed with a secret the app never holds. Every later request
//  carries that token, and the reply is cut down to what that person is
//  allowed to see. A player is sent their own rows and nothing else.
//
//  Rollout is in two stages so nobody is locked out. ENFORCE_AUTH stays
//  off while the updated app reaches people; requests without a token
//  keep working exactly as they do today. Flip it on once everyone has
//  updated and unauthenticated access stops.
//
//=====================================================================


//=====================================================================
//  STEP 1 - RUN THIS ONCE
//=====================================================================
//
//  Put your NEW coach code in the line marked below, then run
//  setupSecurity from the editor's Run menu.
//
//  It must be a NEW code. The old one is in the git history of a public
//  repository permanently, so it has to be treated as public knowledge
//  no matter what the app now says.
//
//  This stores the code and a generated signing secret in Script
//  Properties. They live in the project settings, not in this file, so
//  they are not in the repository and are not shipped to any phone.
//
//  ---- copy from here ----

function setupSecurity(){

  const props=PropertiesService.getScriptProperties();

  //  >>> CHANGE THIS to your new coach code, then run this function <<<
  const NEW_COACH_CODE="CHANGE-ME-BEFORE-RUNNING";

  if(NEW_COACH_CODE=="CHANGE-ME-BEFORE-RUNNING"){

    throw new Error(
      "Edit NEW_COACH_CODE first. Do not reuse the old code - it is "+
      "public in the repository history."
    );

  }

  props.setProperty("COACH_CODE",NEW_COACH_CODE);

  // Signs the tokens. Generated here so it never appears in this file.
  if(!props.getProperty("AUTH_SECRET")){

    props.setProperty(
      "AUTH_SECRET",
      Utilities.getUuid()+Utilities.getUuid()
    );

  }

  // Off means requests with no token still work, so already installed
  // copies of the app keep running while everyone updates.
  if(!props.getProperty("ENFORCE_AUTH")){

    props.setProperty("ENFORCE_AUTH","false");

  }

  Logger.log(
    "Done. Coach code stored, signing secret ready, "+
    "ENFORCE_AUTH is "+props.getProperty("ENFORCE_AUTH")+"."
  );

}

//  ---- to here ----


//=====================================================================
//  STEP 2 - PASTE AT THE BOTTOM OF THE FILE
//=====================================================================
//
//  Everything below goes after the closing brace of doPost. It only
//  adds functions; nothing you already have changes meaning.
//
//  ---- copy from here ----

//=====================================================================
// TOKENS
//=====================================================================

function prop_(key){

  return PropertiesService
      .getScriptProperties()
      .getProperty(key);

}

function enforcing_(){

  return prop_("ENFORCE_AUTH")=="true";

}

// A token is the details, then a signature of those details. Changing
// the details invalidates the signature, and the signature cannot be
// recreated without the secret, which only this script holds.
function sign_(text){

  return Utilities.base64EncodeWebSafe(

    Utilities.computeHmacSha256Signature(
      text,
      prop_("AUTH_SECRET")
    )

  );

}

function makeToken_(role,name,email){

  const body=Utilities.base64EncodeWebSafe(

    JSON.stringify({

      r:role,
      n:name,
      e:email,

      // Thirty days, then signing in again is required.
      x:new Date().getTime()+(30*24*60*60*1000)

    })

  );

  return body+"."+sign_(body);

}

// Returns the signed in identity, or null. Null covers every failure:
// missing, altered, expired, or signed with a different secret.
function readToken_(token){

  if(!token) return null;

  const parts=String(token).split(".");

  if(parts.length!=2) return null;

  if(sign_(parts[0])!=parts[1]) return null;

  let body;

  try{

    body=JSON.parse(
      Utilities.newBlob(
        Utilities.base64DecodeWebSafe(parts[0])
      ).getDataAsString()
    );

  }

  catch(err){

    return null;

  }

  if(!body.x||new Date().getTime()>body.x) return null;

  return body;

}

//=====================================================================
// WHO IS ASKING
//=====================================================================
//
// While ENFORCE_AUTH is off, a request with no token is treated as the
// coach, which is what the app effectively assumed before. That is what
// keeps older installs working during the rollout, and it is exactly
// what turning ENFORCE_AUTH on removes.

function identify_(e){

  const token=e&&e.parameter?e.parameter.token:null;

  const who=readToken_(token);

  if(who) return who;

  if(!enforcing_()){

    return {r:"coach",n:"",e:"",legacy:true};

  }

  return null;

}

function denied_(){

  return json({
    status:"error",
    code:"AUTH_REQUIRED",
    message:"Please sign in again."
  });

}

//=====================================================================
// SIGNING IN
//=====================================================================
//
// Called by the app as a POST with type=login.
//
//   Coach : type=login, role=coach,  code=<the coach code>
//   Player: type=login, role=player, email=<their email>
//
// The coach code is compared here. It is never sent to the app, so
// reading the app cannot reveal it.

function handleLogin_(e){

  const role=e.parameter.role;

  if(role=="coach"){

    const supplied=String(e.parameter.code||"");

    const actual=String(prop_("COACH_CODE")||"");

    if(!actual){

      return json({
        status:"error",
        message:"Coach code is not configured. Run setupSecurity."
      });

    }

    if(supplied!==actual){

      return json({status:"error",message:"Incorrect coach code"});

    }

    return json({

      status:"success",
      role:"coach",
      token:makeToken_("coach","","")

    });

  }

  if(role=="player"){

    const email=String(e.parameter.email||"")
        .trim()
        .toLowerCase();

    if(!email){

      return json({status:"error",message:"Enter Email Address"});

    }

    const rows=getSheet(SHEETS.PLAYERS)
        .getDataRange()
        .getValues();

    const headers=rows[0];

    let emailCol=-1;
    let nameCol=-1;

    for(let j=0;j<headers.length;j++){

      if(String(headers[j]).trim()=="Email Address") emailCol=j;

      if(String(headers[j]).trim()=="Players full name") nameCol=j;

    }

    if(emailCol<0){

      return json({
        status:"error",
        message:"Email Address column not found"
      });

    }

    for(let i=1;i<rows.length;i++){

      const rowEmail=String(rows[i][emailCol])
          .trim()
          .toLowerCase();

      if(rowEmail==email){

        const name=nameCol>=0?String(rows[i][nameCol]).trim():"";

        return json({

          status:"success",
          role:"player",
          playerName:name,
          playerEmail:rowEmail,
          token:makeToken_("player",name,rowEmail)

        });

      }

    }

    return json({status:"error",message:"Player not found"});

  }

  return json({status:"error",message:"Unknown role"});

}

//=====================================================================
// SCOPED DATA
//=====================================================================
//
// The whole point of the change. A coach gets everything. A player gets
// only their own rows, decided here rather than on the phone, so the
// other players' records are never sent in the first place.

function scopedAll_(who){

  const coach=who.r=="coach";

  const name=String(who.n||"").trim().toLowerCase();

  const email=String(who.e||"").trim().toLowerCase();

  function mine(rows,field){

    if(coach) return rows;

    return rows.filter(function(row){

      return String(row[field]||"").trim().toLowerCase()==name;

    });

  }

  return {

    players: coach
        ? buildPlayers()
        : buildPlayers().filter(function(p){

            return String(p["Email Address"]||"")
                .trim()
                .toLowerCase()==email;

          }),

    attendance   : mine(buildAttendance(),"Player Name"),

    competitions : mine(buildCompetitions(),"Player Name"),

    fees: coach
        ? buildFees()
        : buildFees().filter(function(f){

            return String(f.email||"")
                .trim()
                .toLowerCase()==email;

          }),

    events : buildEvents(),

    // Coach pay is nobody else's business. Previously any player could
    // read it straight from the URL.
    salary : coach?buildSalary():[]

  };

}

//  ---- to here ----


//=====================================================================
//  STEP 3 - TWO EDITS INSIDE doPost
//=====================================================================
//
//  3a. As the FIRST thing inside doPost(e), before anything else:
//
//  ---- copy from here ----

  if(e.parameter.type=="login"){

    return handleLogin_(e);

  }

  if(!identify_(e)){

    return denied_();

  }

//  ---- to here ----
//
//
//  3b. Saving and deleting is the coach's job. Immediately after the
//      block above, add:
//
//  ---- copy from here ----

  if(identify_(e).r!="coach"){

    return json({
      status:"error",
      message:"Not allowed"
    });

  }

//  ---- to here ----
//
//  Leave this out if players are meant to record their own fees from
//  the player screen. In that case a player can still write fee rows,
//  which is the current behaviour.
//
//=====================================================================


//=====================================================================
//  STEP 4 - ONE EDIT INSIDE doGet
//=====================================================================
//
//  As the FIRST thing inside doGet(e), before the APP UPDATE block:
//
//  ---- copy from here ----

  // The update check tells the app whether a newer version exists and
  // reveals nothing, so it stays open. Everything else needs a token.
  if(e.parameter.update!="true"){

    const who=identify_(e);

    if(!who) return denied_();

    if(e.parameter.all=="true"){

      return json(scopedAll_(who));

    }

  }

//  ---- to here ----
//
//  If you already pasted the earlier combined endpoint block, DELETE
//  it now. The line above replaces it and is the scoped version.
//
//=====================================================================


//=====================================================================
//  STEP 5 - REDEPLOY, THEN TEST
//=====================================================================
//
//  Deploy > Manage deployments > pencil > Version: New version >
//  Deploy. Keep the SAME deployment or every installed copy breaks.
//
//  With ENFORCE_AUTH still false, nothing should change for anyone.
//  Open this in a browser to confirm the app still works:
//
//    <your exec url>?all=true
//
//  You should get one object containing players, attendance, fees,
//  competitions, events and salary.
//
//
//=====================================================================
//  STEP 6 - TURN IT ON, ONCE EVERYONE HAS THE NEW APP
//=====================================================================
//
//  Project Settings > Script Properties > set ENFORCE_AUTH to true.
//  No redeploy needed; it takes effect immediately.
//
//  Then check the same URL again. It should now answer:
//
//    {"status":"error","code":"AUTH_REQUIRED",...}
//
//  That is the whole point: a bare URL stops working, and the data is
//  only reachable by someone who signed in.
//
//  To reverse it, set ENFORCE_AUTH back to false.
//
//=====================================================================
