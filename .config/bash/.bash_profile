case $- in
	*i*) ;;
	*) return;;
esac

for file in /home/toby/.config/bash/.{bash_prompt,exports,aliases,functions}; do
    [ -r "$file" ] && source "$file"
done
unset file
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && export LESSOPEN="|lesspipe %s"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi
case "$TERM" in
	xterm-color) color_prompt=yes;;
esac
force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi
case "$TERM" in
	xterm*|rxvt*)
		PS1="\\[\\e]0;${debian_chroot:+($debian_chroot)}\\u@\\h: \\w\\a\\]$PS1"
		;;
	*)
		;;
esac
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

COLOR_SCHEME=dark # dark/light
if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
    export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
    export TERM=xterm-256color
fi
### CHANGE TITLE OF TERMINALS
case ${TERM} in
  xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|alacritty|st|konsole*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
        ;;
  screen*)
    PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
    ;;
esac

#
# Bash Completion
if [ -f /usr/share/bash-completion/bash_completion ]
then
	source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]
then
	source /etc/bash_completion
fi

# enable terminal linewrap
setterm -linewrap on 2> /dev/null


# colorize ls
[ -x /usr/bin/dircolors ] && eval "$(dircolors -b)"

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
	PS1="\[\e]0;\u@\h: \w\a\]$PS1"
	;;
esac
if ! shopt -oq posix; then
	if [[ -f /usr/share/bash-completion/bash_completion ]]; then
		# shellcheck source=/dev/null
		. /usr/share/bash-completion/bash_completion
	elif [[ -f /etc/bash_completion ]]; then
		# shellcheck source=/dev/null
		. /etc/bash_completion
	elif [[ -f /usr/local/etc/bash_completion ]]; then
		# shellcheck source=/dev/null
		. /usr/local/etc/bash_completion
	fi
fi
if [[ -d /etc/bash_completion.d/ ]]; then
	for file in /etc/bash_completion.d/* ; do
		# shellcheck source=/dev/null
		source "$file"
	done
fi

# We do this before the following so that all the paths work.
for file in ~/.{bash_prompt,aliases,functions,path,dockerfunc,extra,exports}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		# shellcheck source=/dev/null
		source "$file"
	fi
done
unset file

# Start the gpg-agent if not already running
if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
	gpg-connect-agent /bye >/dev/null 2>&1
fi
gpg-connect-agent updatestartuptty /bye >/dev/null
# use a tty for gpg
# solves error: "gpg: signing failed: Inappropriate ioctl for device"
GPG_TTY=$(tty)
export GPG_TTY
# Set SSH to use gpg-agent
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
	if [[ -z "$SSH_AUTH_SOCK" ]] || [[ "$SSH_AUTH_SOCK" == *"apple.launchd"* ]]; then
		SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
		export SSH_AUTH_SOCK
	fi
fi

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null
done

# Add tab completion for SSH hostnames based on ~/.ssh/config
# ignoring wildcards
[[ -e "$HOME/.ssh/config" ]] && complete -o "default" \
	-o "nospace" \
	-W "$(grep "^Host" ~/.ssh/config | \
	grep -v "[?*]" | cut -d " " -f2 | \
	tr ' ' '\n')" scp sftp ssh

# source kubectl bash completion
if hash kubectl 2>/dev/null; then
	# shellcheck source=/dev/null
	source <(kubectl completion bash)
fi

# get the gh completions
if hash gh 2>/dev/null; then
	eval "$(gh completion -s bash)"
fi

# get the kittycad completions
if hash kittycad 2>/dev/null; then
	eval "$(kittycad completion -s bash)"
fi

# source travis bash completion
if [[ -f "${HOME}/.travis/travis.sh" ]]; then
	# shellcheck source=/dev/null
	source "${HOME}/.travis/travis.sh"
fi


