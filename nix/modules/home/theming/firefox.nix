{...}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      isDefault = true;
      settings = {
        # Enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # Dark theme preference
        "ui.systemUsesDarkTheme" = 1;
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
      };
      userChrome = ''
        /* Everforest Dark Theme for Firefox */
        :root {
          --everforest-bg-dim: #232A2E;
          --everforest-bg0: #2D353B;
          --everforest-bg1: #343F44;
          --everforest-bg2: #3D484D;
          --everforest-bg3: #475258;
          --everforest-bg4: #4F585E;
          --everforest-fg: #D3C6AA;
          --everforest-grey0: #7A8478;
          --everforest-grey1: #859289;
          --everforest-grey2: #9DA9A0;
          --everforest-red: #E67E80;
          --everforest-orange: #E69875;
          --everforest-yellow: #DBBC7F;
          --everforest-green: #A7C080;
          --everforest-aqua: #83C092;
          --everforest-blue: #7FBBB3;
          --everforest-purple: #D699B6;

          /* Firefox color mappings */
          --lwt-accent-color: var(--everforest-bg0) !important;
          --lwt-text-color: var(--everforest-fg) !important;
          --toolbar-bgcolor: var(--everforest-bg1) !important;
          --toolbar-color: var(--everforest-fg) !important;
          --toolbar-field-background-color: var(--everforest-bg2) !important;
          --toolbar-field-color: var(--everforest-fg) !important;
          --toolbar-field-border-color: var(--everforest-bg3) !important;
          --toolbar-field-focus-background-color: var(--everforest-bg1) !important;
          --toolbar-field-focus-border-color: var(--everforest-green) !important;
          --urlbar-popup-url-color: var(--everforest-green) !important;
          --tab-selected-bgcolor: var(--everforest-bg2) !important;
          --tab-selected-textcolor: var(--everforest-fg) !important;
          --tab-loading-fill: var(--everforest-green) !important;
          --arrowpanel-background: var(--everforest-bg1) !important;
          --arrowpanel-color: var(--everforest-fg) !important;
          --arrowpanel-border-color: var(--everforest-bg3) !important;
        }

        /* Tab bar background */
        #TabsToolbar {
          background-color: var(--everforest-bg-dim) !important;
        }

        /* Active tab */
        .tab-background[selected="true"] {
          background-color: var(--everforest-bg1) !important;
        }

        /* Inactive tabs */
        .tab-background:not([selected="true"]) {
          background-color: var(--everforest-bg0) !important;
        }

        /* Navigation bar */
        #nav-bar {
          background-color: var(--everforest-bg1) !important;
          border-bottom: 1px solid var(--everforest-bg3) !important;
        }

        /* URL bar */
        #urlbar-background {
          background-color: var(--everforest-bg2) !important;
          border-color: var(--everforest-bg3) !important;
        }

        #urlbar[focused="true"] > #urlbar-background {
          border-color: var(--everforest-green) !important;
        }

        /* Bookmarks bar */
        #PersonalToolbar {
          background-color: var(--everforest-bg0) !important;
        }

        /* Sidebar */
        #sidebar-box {
          background-color: var(--everforest-bg0) !important;
          color: var(--everforest-fg) !important;
        }

        /* Menu popup panels */
        menupopup, panel {
          --panel-background: var(--everforest-bg1) !important;
          --panel-color: var(--everforest-fg) !important;
        }
      '';
      userContent = ''
        /* Everforest for Firefox internal pages */
        @-moz-document url("about:newtab"), url("about:home"), url("about:blank") {
          body {
            background-color: #2D353B !important;
          }
        }
      '';
    };
  };
}
