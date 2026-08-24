#===============================================================================
# FILE: Makefile
# Project: firefox-nix
#===============================================================================


#===============================================================================
# PHONY
#===============================================================================

.PHONY: all clean env homeconf


#===============================================================================
# persistent storage
#===============================================================================

# dofiles directory
DOTFILES_DIR 	:= dotfiles
CACHE_DIR    	:= $(DOTFILES_DIR)/cache
CONFIG_DIR	:= $(DOTFILES_DIR)/config
LOCAL_DIR	:= $(DOTFILES_DIR)/local
PULSE_DIR       := $(CONFIG_DIR)/pulse
DEFAULTPA_FILE  := $(CONFIG_DIR)/pulse/default.pa

# Application Configuration Paths
NIX_DIR		:= $(CONFIG_DIR)/nix
NIX_FILE	:= $(NIX_DIR)/nix.conf
MOZILLA_DIR  	:= $(CONFIG_DIR)/mozilla
ENV_FILE     	:= .env

# Home Manager Paths
HOME_MANAGER_DIR := $(CONFIG_DIR)/home-manager
FLAKE_NIX        := $(HOME_MANAGER_DIR)/flake.nix
HOME_NIX         := $(HOME_MANAGER_DIR)/home.nix
NIX_VERSION	 := 26.05

#===============================================================================
# default target
#===============================================================================

all: env homeconf


#===============================================================================
# create directories
#===============================================================================

dotfiles: 
	mkdir -p $(DOTFILES_DIR)


config: dotfiles
	mkdir -p $(CONFIG_DIR)


local: config
	mkdir -p $(LOCAL_DIR)


mozilla: local
	mkdir -p $(MOZILLA_DIR)


#===============================================================================
# pulse directory
#===============================================================================

pulse: mozilla
	mkdir -p $(PULSE_DIR)


#===============================================================================
# pulseaudio default.pa
#===============================================================================

defaultpa: pulse
	echo 'default-server = /tmp/pulseaudio.socket' > $(DEFAULTPA_FILE)


#===============================================================================
# nix
#===============================================================================

nixdir: defaultpa
	mkdir -p $(NIX_DIR)


#===============================================================================
# nix flakes
#===============================================================================

nixconf: nixdir
	@_USER=`id -un`; \
	printf "%s\n" \
	"experimental-features = nix-command flakes" \
	"filter-syscalls = false" \
	"sandbox = false" \
	"trusted-users = root $${_USER}" > $(NIX_FILE)


#===============================================================================
# cache
#===============================================================================

cache: nixconf
	mkdir -p $(CACHE_DIR)


#===============================================================================
# Environment Configuration Target
# Generates a personalized .env file automatically
#===============================================================================

env: cache
	@_USER=`id -un`; \
	_UID=`id -u`; \
	_HOST=`hostname -s`; \
	_MNT=""; \
	for _dir in Downloads Download downloads download; do \
		if [ -d "/home/$$_USER/$$_dir" ]; then \
			_MNT="/home/$$_USER/$$_dir"; \
			break; \
		fi; \
	done; \
	if [ -z "$$_MNT" ]; then \
		_MNT="/home/$$_USER/downloads"; \
	fi; \
	printf "%s\n" \
	"#===============================================================================" \
	"# FILE: .env" \
	"# Project: firefox-nix" \
	"#===============================================================================" \
	"" \
	"" \
	"#===============================================================================" \
	"# XDG_RUNTIME_DIR" \
	"#===============================================================================" \
	"" \
	"HOST_XDG_RUNTIME_DIR=\$${XDG_RUNTIME_DIR}" \
	"" \
	"" \
	"#===============================================================================" \
	"# XDG_SESSION_TYPE" \
	"#===============================================================================" \
	"" \
	"HOST_XDG_SESSION_TYPE=\$${XDG_SESSION_TYPE}" \
	"" \
	"" \
	"#===============================================================================" \
	"# DBUS_SESSION_BUS_ADDRESS" \
	"#===============================================================================" \
	"" \
	"HOST_DBUS_SESSION_BUS_ADDRESS=\$${DBUS_SESSION_BUS_ADDRESS}" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_UID (Automatically detected from FreeBSD)" \
	"#===============================================================================" \
	"" \
	"HOST_UID=$$_UID" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_USER (Automatically detected from FreeBSD)" \
	"#===============================================================================" \
	"" \
	"HOST_USER=$$_USER" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_HOSTNAME (Automatically detected from FreeBSD)" \
	"#===============================================================================" \
	"" \
	"HOST_HOSTNAME=$$_HOST" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_BIN" \
	"# Bin directory mounted into the container" \
	"#===============================================================================" \
	"" \
	"HOST_BIN=bin" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_MOUNT" \
	"# Directory mounted from FreeBSD into the container" \
	"#===============================================================================" \
	"" \
	"HOST_MOUNT=$$_MNT" \
	"" \
	"" \
	"#===============================================================================" \
	"# HOST_LANG (Host language)" \
	"#===============================================================================" \
	"" \
	"HOST_LANG=$${LANG}" > $(ENV_FILE);


#===============================================================================
# Home Manager Flake & Config Target
#===============================================================================

homeconf: env
	@_USER=`id -un`; \
	_HOST=`hostname -s`; \
	mkdir -p $(HOME_MANAGER_DIR); \
	cp ../../../assets/applications/browsers/firefox/nix/firefox.nix $(HOME_MANAGER_DIR)/firefox.nix; \
	printf "%s\n" \
	"{" \
	"  description = \"Home Manager configuration\";" \
	"" \
	"  inputs = {" \
	"    nixpkgs.url = \"github:nixos/nixpkgs/nixos-unstable\";" \
	"    nixpkgs-stable.url = \"github:nixos/nixpkgs/nixos-$(NIX_VERSION)\";" \
	"    nixpkgs-master.url = \"github:nixos/nixpkgs/master\";" \
	"" \
	"    home-manager = {" \
	"      url = \"github:nix-community/home-manager\";" \
	"      inputs.nixpkgs.follows = \"nixpkgs\";" \
	"    };" \
	"  };" \
	"" \
	"  outputs = inputs@{" \
	"    self," \
	"    nixpkgs," \
	"    nixpkgs-stable," \
	"    nixpkgs-master," \
	"    home-manager," \
	"    ... }:" \
	"    let" \
	"      system = \"x86_64-linux\";" \
	"      username = \"$${_USER}\";" \
	"      hostname = \"$${_HOST}\";" \
	"    in" \
	"    {" \
	"      homeConfigurations.\"\$${username}@\$${hostname}\" = home-manager.lib.homeManagerConfiguration {" \
	"        pkgs = nixpkgs.legacyPackages.\$${system};" \
	"        " \
	"        extraSpecialArgs = {" \
	"          pkgs-stable = import nixpkgs-stable {" \
	"            inherit system;" \
	"            config.allowUnfree = true;" \
	"            system-openssl = true;" \
	"          };" \
	"          pkgs-master = import nixpkgs-master {" \
	"            inherit system;" \
	"            config.allowUnfree = true;" \
	"          };" \
	"        };" \
	"        " \
	"        modules = [" \
	"          ./home.nix" \
	"        ];" \
	"      };" \
	"    };" \
	"}" > $(FLAKE_NIX); \
	printf "%s\n" \
	"{" \
	"  config," \
	"  pkgs," \
	"  pkgs-stable," \
	"  pkgs-master," \
	"  ..." \
	"}: {" \
	"  home.username = \"$${_USER}\";" \
	"  home.homeDirectory = \"/home/$${_USER}\";" \
	"  home.stateVersion = \"$(NIX_VERSION)\";" \
	"" \
	"  nixpkgs.config.allowUnfree = true;" \
	"" \
	"  imports = [ ./firefox.nix ];" \
	"" \
	"home.packages = with pkgs; [" \
	"  adwaita-qt6" \
	"  adwaita-icon-theme" \
	"  gnome-themes-extra" \
	"  widevine-cdm" \
	"];" \
	"" \
	"# gtk" \
	"gtk = {" \
	"  enable = true;" \
	"  gtk4.theme = null;" \
	"  gtk3.extraConfig = {" \
	"    gtk-application-prefer-dark-theme = true;" \
	"  };" \
	"  gtk4.extraConfig = {" \
	"    gtk-application-prefer-dark-theme = true;" \
	"  };" \
	"};" \
	"# qt" \
	"qt = {" \
	"    enable = true;" \
	"    platformTheme.name = \"adwaita\";"\
	"    style = {" \
	"      name = \"adwaita-dark\";" \
	"      package = pkgs.adwaita-qt6;" \
	"   };" \
	"};" \
	"" \
	"  home.file = {};" \
	"" \
	"  home.sessionVariables = {};" \
	"" \
	"  programs.home-manager.enable = true;" \
	"}" > $(HOME_NIX)


#===============================================================================
# Clean target to wipe the structure out if you need to reset
#===============================================================================

clean:
	rm -rf $(DOTFILES_DIR)
	rm -f $(ENV_FILE)
