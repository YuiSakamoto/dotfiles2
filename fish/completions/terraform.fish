
function __complete_terraform
    set -lx COMP_LINE (commandline -cp)
    test -z (commandline -ct)
    and set COMP_LINE "$COMP_LINE "
    /usr/local/Cellar/tfenv/3.0.0/versions/1.3.3/terraform
end
complete -f -c terraform -a "(__complete_terraform)"

