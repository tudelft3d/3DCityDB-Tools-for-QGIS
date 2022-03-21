"""This package contains set-up functions for each QT widget in the GUI of the
plugin. The functions are called as events from signals.

The logic behind all of the functions is that are responsible to configure
the plugin, depending on the emitted signal of a widget.

The set-up can consist of many things but it is mainly responsible to
activate/deactivate widgets, reset widgets, change informative text,
call other functions, execute back-end operations and more.

Example: When another 'Existing Connection' is selected, then the signal
'currentIndexChanged' is emitted from the 'cbxExistingConnection' widget.
The event linked to this signal executes the function
'cbxExistingConnection_setup' which is responsible for the set-up."""
