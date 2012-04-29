#!/bin/sh

# Note, this script (written by Zachary Bornheimer to complete the Interface application) requires
# the folder Finisher to exist with the ANUBIS.icns file and the Interface.plist.  The Interface.app
# application is required to be in the same directory sublevel as this script and the Finisher directory.

cd .;
cp "Finisher/Interface.plist" "Interface.app/Contents/Info.plist";
cp "Finisher/ANUBIS.icns" "Interface.app/Contents/Resources/ANUBIS.icns";