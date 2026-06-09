(() => {
  const launcherFrame = document.querySelector("[data-launcher-frame]");
  const launcherLabel = document.querySelector("[data-launcher-label]");
  const launcherLinks = Array.from(document.querySelectorAll("[data-screen-target]"));
  const launcherKey = "od-daily-companion-last-screen";

  const updateLauncher = (path) => {
    if (!launcherFrame) return;
    launcherFrame.src = `/frames/iphone-15-pro.html?screen=${path}`;
    const active = launcherLinks.find((link) => link.dataset.screenTarget === path);
    if (launcherLabel && active) {
      launcherLabel.textContent = active.dataset.screenLabel || "";
    }
    launcherLinks.forEach((link) => {
      link.classList.toggle("is-active", link.dataset.screenTarget === path);
    });
    try {
      localStorage.setItem(launcherKey, path);
    } catch (error) {
      void error;
    }
  };

  if (launcherFrame && launcherLinks.length) {
    const initial = (() => {
      try {
        return localStorage.getItem(launcherKey) || "screens/home.html";
      } catch (error) {
        void error;
        return "screens/home.html";
      }
    })();
    updateLauncher(initial);
    launcherLinks.forEach((link) => {
      link.addEventListener("click", (event) => {
        event.preventDefault();
        updateLauncher(link.dataset.screenTarget);
      });
    });
  }

  const sheet = document.querySelector("[data-sheet]");
  const openSheet = document.querySelector("[data-open-sheet]");
  const closeSheet = document.querySelector("[data-close-sheet]");
  if (sheet && openSheet) {
    openSheet.addEventListener("click", () => {
      sheet.classList.add("open");
    });
  }
  if (sheet && closeSheet) {
    closeSheet.addEventListener("click", () => {
      sheet.classList.remove("open");
    });
  }

  const explainButton = document.querySelector("[data-open-reason]");
  if (explainButton) {
    explainButton.addEventListener("click", () => {
      window.location.href = "reason.html";
    });
  }

  const reportButtons = Array.from(document.querySelectorAll("[data-go-report]"));
  reportButtons.forEach((button) => {
    button.addEventListener("click", () => {
      window.location.href = "report.html";
    });
  });

  const segmentButtons = Array.from(document.querySelectorAll("[data-report-tab]"));
  const segmentPanels = Array.from(document.querySelectorAll("[data-report-panel]"));
  if (segmentButtons.length && segmentPanels.length) {
    const setActiveTab = (target) => {
      segmentButtons.forEach((button) => {
        const active = button.dataset.reportTab === target;
        button.classList.toggle("is-active", active);
        button.setAttribute("aria-selected", String(active));
      });
      segmentPanels.forEach((panel) => {
        const active = panel.dataset.reportPanel === target;
        panel.classList.toggle("is-active", active);
        panel.hidden = !active;
      });
    };

    const initial = segmentButtons.find((button) => button.classList.contains("is-active")) || segmentButtons[0];
    setActiveTab(initial.dataset.reportTab);

    segmentButtons.forEach((button) => {
      button.addEventListener("click", () => {
        setActiveTab(button.dataset.reportTab);
      });
    });
  }
})();
