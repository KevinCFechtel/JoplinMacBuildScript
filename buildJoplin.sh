#!/bin/zsh
if [ -z "$1" ]; then
	echo "$0 [version]"
	echo "Builds Joplin [version] in ARM64, e.g.:"
	echo "$0 2.10.18"
	echo "brew install jq"
	echo "brew install jo"
	echo "brew install node"
	echo "brew install yarn"
	exit
fi

# Cloning the requested version of Joplin from Github
echo "Cloning the requested version of Joplin from Github"
cd ~/Downloads
git clone --depth 1 --branch "v$1" https://github.com/laurent22/joplin.git

# Modifying the target for the build (Apple Silicon instead of Intel)
cd joplin
TMP=$(mktemp)
VALUE=$(jo target=zip "arch[]=arm64")
jq ".build.mac.target=$VALUE" packages/app-desktop/package.json > $TMP
mv $TMP packages/app-desktop/package.json

# Downloading and building dependancies
echo "Downloading and building dependancies"
yarn install
cd packages/app-desktop

# Let's finally build Joplin!
echo "Let's finally build Joplin!"
yarn run dist --publish=never --arm64
EXIT=$?

# Joplin.app will be copied to the root of the Downloads folder
echo "Copy Joplin.app to the root of the Downloads folder"
cp -R dist/mac-arm64/Joplin.app ~/Downloads
cd ~/Downloads

# Remove the files downloaded from Github if all went well
if [[ $EXIT -eq 0 ]]; then
	echo "Remove the files downloaded from Github since all went well"
	rm -rf joplin
fi
