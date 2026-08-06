import 'package:flutter/material.dart';

/// Lets code outside the widget tree reach the current screen.
///
/// The update check runs in the background now, so by the time it has an
/// answer the splash screen it started from is long gone. This key finds
/// whatever screen is showing instead.
final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();
