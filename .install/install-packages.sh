if [[ "$force_install" == "1" ]] ;then
    echo "Force installation of all packages..."
    _forcePackagesPacman "${packagesPacman[@]}";
    _forcePackagesYay "${packagesYay[@]}";
else
    echo "Install only missing packages..."
    _installPackagesPacman "${packagesPacman[@]}";
    _installPackagesYay "${packagesYay[@]}";
fi

if gum confirm "Do you want to install Atuin?"; then
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
fi
echo
