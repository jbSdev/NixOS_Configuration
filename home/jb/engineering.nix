{ pkgs, ... }: {

    home.packages = with pkgs; [
        # 3D / Mechanical
        blender
        bambu-studio
        freecad
        openscad

        # PCB / Electronics
        kicad

        # Utilities
        sigrok-cli
        pulseview
        minicom
    ];

}
