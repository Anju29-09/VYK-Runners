//=====================================================================
//  ADDITIONS ONLY — nothing existing changes
//=====================================================================
//
//  Every request to this web app costs roughly two seconds of Apps
//  Script startup no matter how little data comes back. The app was
//  making up to five separate calls to draw one screen, so it paid that
//  startup five times over.
//
//  This adds one endpoint that reads every sheet inside a single call.
//  The startup is paid once instead of five times.
//
//  The arrays it returns are the same shapes the existing endpoints
//  already return, so nothing that reads them needs to change.
//
//=====================================================================


//=====================================================================
//  STEP 1
//=====================================================================
//
//  Paste this block inside doGet(e), immediately AFTER the closing
//  brace of the "APP UPDATE" block and BEFORE the "EVENTS" block.
//
//  Placement matters. The "PLAYER DETAILS" block further down fires
//  whenever none of the known parameters are set, and it does not know
//  about "all", so this has to be reached first.
//
//  ---- copy from here ----

  //=========================
  // EVERYTHING AT ONCE
  //=========================

  if(e.parameter.all=="true"){

    return json({

      players      : buildPlayers(),
      attendance   : buildAttendance(),
      fees         : buildFees(),
      competitions : buildCompetitions(),
      events       : buildEvents(),
      salary       : buildSalary()

    });

  }

//  ---- to here ----


//=====================================================================
//  STEP 2
//=====================================================================
//
//  Paste everything below at the very BOTTOM of the file, after the
//  closing brace of doPost.
//
//  These are deliberately kept separate from the branches inside
//  doGet rather than shared with them, so that adding this endpoint
//  cannot affect anything that already works. They repeat the same
//  row mapping on purpose.
//
//  ---- copy from here ----

//=====================================================================
// BUILDERS FOR THE COMBINED ENDPOINT
//=====================================================================

// One bad or renamed sheet returns an empty list instead of failing the
// whole response, so a problem with Salary cannot stop Attendance from
// loading.
function safely(fn){

  try{

    return fn();

  }

  catch(err){

    return [];

  }

}

function buildPlayers(){

  return safely(function(){

    const data=getSheet(SHEETS.PLAYERS)
        .getDataRange()
        .getValues();

    const headers=data[0];

    let output=[];

    for(let i=1;i<data.length;i++){

      let row={};

      for(let j=0;j<headers.length;j++){

        row[headers[j]]=String(data[i][j]);

      }

      output.push(row);

    }

    return output;

  });

}

function buildAttendance(){

  return safely(function(){

    const data=getSheet(SHEETS.ATTENDANCE)
        .getDataRange()
        .getValues();

    let output=[];

    for(let i=1;i<data.length;i++){

      output.push({

        ID:data[i][0],
        Timestamp:data[i][1],
        Date:String(data[i][2]).replace(/^'/,""),
        "Player Name":data[i][3],
        Group:data[i][4],
        Status:data[i][5]

      });

    }

    return output;

  });

}

function buildFees(){

  return safely(function(){

    // getDisplayValues, matching the existing fees endpoint, so the
    // amounts arrive already formatted the way the app expects.
    const data=getSheet(SHEETS.FEES)
        .getDataRange()
        .getDisplayValues();

    let output=[];

    for(let i=1;i<data.length;i++){

      output.push({

        id:data[i][0],
        timestamp:data[i][1],
        player:data[i][2],
        email:data[i][3],
        month:data[i][4],
        monthlyFee:data[i][5],
        group:data[i][6],
        amount:data[i][7],
        status:data[i][8]

      });

    }

    return output;

  });

}

function buildCompetitions(){

  return safely(function(){

    const data=getSheet(SHEETS.COMPETITIONS)
        .getDataRange()
        .getValues();

    let output=[];

    for(let i=1;i<data.length;i++){

      output.push({

        ID:data[i][0],
        Timestamp:data[i][1],
        Date:data[i][2],
        "Player Name":data[i][3],
        Group:data[i][4],
        Event:data[i][5],
        Result:data[i][6]

      });

    }

    return output;

  });

}

function buildEvents(){

  return safely(function(){

    const data=getSheet(SHEETS.EVENTS)
        .getDataRange()
        .getValues();

    let output=[];

    for(let i=1;i<data.length;i++){

      if(data[i][0]!=""){

        output.push(data[i][0]);

      }

    }

    return output;

  });

}

function buildSalary(){

  return safely(function(){

    const data=getSheet(SHEETS.SALARY)
        .getDataRange()
        .getValues();

    const headers=data[0];

    let output=[];

    for(let i=1;i<data.length;i++){

      let row={};

      for(let j=0;j<headers.length;j++){

        if(headers[j]=="Month"){

          row["Month"]=Utilities.formatDate(

              new Date(data[i][j]),
              Session.getScriptTimeZone(),
              "yyyy-MM"

          );

        }

        else{

          row[headers[j]]=String(data[i][j]);

        }

      }

      output.push(row);

    }

    return output;

  });

}

//  ---- to here ----


//=====================================================================
//  STEP 3  (optional, but worth it now)
//=====================================================================
//
//  Your getSheet opens the spreadsheet again on every call. The new
//  endpoint calls it six times in one run, so it would open the same
//  file six times.
//
//  REPLACE your existing getSheet with this. Behaviour is identical —
//  it also drops the hard-coded ID and uses the SPREADSHEET_ID
//  constant you already declared.
//
//  ---- copy from here ----

let _spreadsheet=null;

function getSheet(name){

  // Opened once per run rather than once per sheet.
  if(!_spreadsheet){

    _spreadsheet=SpreadsheetApp.openById(SPREADSHEET_ID);

  }

  return _spreadsheet.getSheetByName(name);

}

//  ---- to here ----


//=====================================================================
//  STEP 4 — REDEPLOY
//=====================================================================
//
//  Deploy > Manage deployments > pencil icon > Version: New version
//  > Deploy.
//
//  Keep the SAME deployment so the URL does not change. If the URL
//  changes, every copy of the app already installed stops working.
//
//  Then check it in a browser:
//
//    <your exec url>?all=true
//
//  You should see one object with players, attendance, fees,
//  competitions, events and salary inside it.
//
//=====================================================================
