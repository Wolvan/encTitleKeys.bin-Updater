
#encTitleKeys.bin-Updater
A tool to easily update the encTitleKeys.bin for [freeShop](https://github.com/Cruel/freeShop) based on [lpp-3ds](https://github.com/Rinnegatamante/lpp-3ds)

##Usage
Simply download the .cia file from the [releases page](/releases) and install it with your favorite .cia Installer, for example FBI. You can also just scan the QR Code from the releases page as well.

Open up the App and select `Download latest encTitleKeys.bin`

You can also use the .3ds version for a flashcard or the .3dsx version for *hax.

Note: The .3dsx version does not support launching freeShop through it, the option is disabled.

##Build instructions
The building is made possible through a `make` script, meaning you need to have `make` installed and in your path. If you already use devkitArm then you are good to go

Just run `make` (or `make all`/`make build`) to get your binaries in the build directory

`build 3ds`, `build 3dsx` and `build cia` are also available in case not all binaries need to be built.

You can also use `make clean` to remove all built files.

##Additional help
Need help with the tool? Or maybe you'd like to modify it but have no idea how or where to start? Join [This Discord channel ![](https://discordapp.com/api/servers/175668882231525376/widget.png)](https://discord.gg/fXHkQNP) which I usually hang out with and ask away, I am always happy to help.

##Credits

[Cruel](https://github.com/Cruel/) - for making [freeShop](https://github.com/Cruel/freeShop)

[MatMaf](https://github.com/MatMaf/) - for making the first version of the [Updater](https://github.com/MatMaf/encTitleKeys.bin-Updater)

[Rinnegatamante](https://github.com/Rinnegatamante/) - for making [lpp-3ds](https://github.com/Rinnegatamante/lpp-3ds)

[3ds.titlekeys.com](https://3ds.titlekeys.com/) - for collecting all the titlekeys
