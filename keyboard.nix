let
  layoutName = "american-qwerty-danish";
in
{
  config.services.xserver = {
    xkb.layout = layoutName;
    # no variant
    xkb.options = "lv3:ralt_switch,lv3:menu_switch";

    xkb.extraLayouts.${layoutName} = rec {
      description = "American QWERTY with Danish æ/ø/å on AltGr ; ' [";
      languages = [ "eng" "dan" ];

      symbolsFile = builtins.toFile "symbols-${layoutName}" ''
        xkb_symbols "basic" {
            include "pc"
            include "us"
            include "inet(evdev)"

            name[Group1] = "${description}";

            // Put æ ø å on ; ' [
            key <AC10> { [ semicolon,  colon,    ae,      AE      ] };
            key <AC11> { [ apostrophe, quotedbl, oslash,  Oslash  ] };
            key <AD11> { [ bracketleft, braceleft, aring, Aring  ] };
        };
      '';
    };
  };
}
