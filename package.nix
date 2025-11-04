{
  lib,
  stdenv,
  fetchurl,
  fetchzip,
  makeDesktopItem,
  makeWrapper,
  unzip,

  jdk17,
  openjfx,

  libGL,
  libXxf86vm,
}:
let
  pname = "craftland-launcher";

  jdk = jdk17.override {
    enableJavaFX = true;
    openjfx_jdk = openjfx.override { withWebKit = true; };
  };

  runtimeLibs = [
    libGL # libGL.so.1
    libXxf86vm # https://github.com/NixOS/nixpkgs/pull/51350
  ];

  launcherJar = fetchurl {
    url = "https://craftland.org/mod/2.0/craftlandlauncher.jar";
    hash = "sha256-m+4Uv7cdStI17bl8WC2Y7IyUI6UI+SUGc7e9B305WhQ=";
  };

  loaderJar = fetchurl {
    url = "https://craftland.org/mod/2.0/loaderv3.jar";
    hash = "sha256-BLxhInMvMDWnXCkBPrHMq+04egZnHHrsIZNxm8uvwFo=";
  };

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Craftland Launcher";
    comment = "Play on the Craftland Aether server";
    icon = pname;
    exec = pname;
  };
in
stdenv.mkDerivation rec {
  inherit pname;
  version = "4.5"; # https://craftland.org/mod/2.0/launcherversion.php

  src = fetchzip {
    url = "https://craftland.org/files/craftland-linux-x64.zip";
    hash = "sha256-4j911jD6Gb1LKxuF8zC1z0dJFDOaNgr/wbpa0BlnvR0=";
  };

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  installPhase = ''
    mkdir -p $out/lib
    cp -r lib/* $out/lib/

    cp ${launcherJar} $out/lib/launcher.jar
    cp ${loaderJar} $out/lib/loader.jar

    mkdir -p $out/bin
    makeWrapper ${jdk}/bin/java $out/bin/${pname} \
      --add-flags "--add-exports javafx.web/com.sun.javafx.webkit=ALL-UNNAMED" \
      --add-flags "-classpath '$out/lib/*' org.craftland.launcher.Main" \
      --prefix PATH : ${jdk}/bin \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath runtimeLibs} \
      --set _JAVA_OPTIONS '--add-opens=java.base/java.util=ALL-UNNAMED'

    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop

    for size in 16 32 64 128; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      unzip -p ${launcherJar} img/cube"$size".png > $out/share/icons/hicolor/"$size"x"$size"/apps/${pname}.png
    done
  '';

  meta = {
    homepage = "https://craftland.org/";
    description = "Craftland Aether server launcher";
    longDescription = ''
      Craftland is a heavily modified Minecraft server that includes plenty of
      mods, including the Aether!
    '';
    mainProgram = pname;
    platforms = [
      "x86_64-linux"
    ];
  };
}
