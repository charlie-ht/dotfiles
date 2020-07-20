alias cdeb_pkg_update='sudo apt update'
alias cdeb_pkg_install='sudo apt install'
alias cdeb_pkg_upgrade='sudo apt upgrade'
cdeb_pkg_remove ()
{
    sudo apt remove $1 && sudo apt purge $1 && sudo apt autoclean
}
alias cdeb_pkg_autoremove='sudo apt autoremove'
alias cdeb_pkg_info='apt show'
alias cdeb_pkg_search='apt search'
alias cdeb_pkg_why='aptitude why'
alias cdeb_pkg_list_manuals="aptitude search '~i!~M'"

search_wk_list()
{
    gsearch "site:lists.webkit.org $@"
}
cdeb_search_home()
{
    gsearch "site:debian.org $@"
}
cdeb_search_wiki()
{
    gsearch "site:wiki.debian.org $@"
}
cdeb_search_lists()
{
    gsearch "site:lists.debian.org $@"
}
cdeb_openbug () {
	local id=$1
	local url="http://bugs.debian.org/${id}"
	sensible-browser $url
}
cdeb_pkgbugs () {
	local pkg=$1
	local url="http://bugs.debian.org/${pkg}"
	sensible-browser $url
}
