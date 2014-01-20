My env files.

Remember to install `git`

In `~/.gitconfig` put

```
[include]
	path = ~/env/gitconfig
```

In `~/.zshrc` put

```
source ~/env/zshrc
```

Install [homebrew](http://brew.sh/) and then

```bash
$ cd env; brew bundle
```

