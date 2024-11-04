# Variables
INSTALL_DIR := /opt/ansible-task-runner
BASH_SCRIPT := run.sh
PYTHON_SCRIPT := runner.py
LINK_NAME := /usr/local/bin/atr

.PHONY: install
install: create_dir copy_files set_permissions link
	@echo "Installation complete. You can now run the script globally with the command: atr"

.PHONY: create_dir
create_dir:
	@mkdir -p $(INSTALL_DIR)

.PHONY: copy_files
copy_files: $(BASH_SCRIPT) $(PYTHON_SCRIPT)
	@echo "Copying $(BASH_SCRIPT) and $(PYTHON_SCRIPT) to $(INSTALL_DIR)..."
	@cp $(BASH_SCRIPT) $(INSTALL_DIR)/
	@cp $(PYTHON_SCRIPT) $(INSTALL_DIR)/

.PHONY: set_permissions
set_permissions:
	@chmod +x $(INSTALL_DIR)/$(BASH_SCRIPT)

.PHONY: link
link:
	@ln -sf $(INSTALL_DIR)/$(BASH_SCRIPT) $(LINK_NAME)

.PHONY: uninstall
uninstall:
	@rm -rf $(INSTALL_DIR) $(LINK_NAME)

.PHONY: clean
clean:
	@rm -rf $(INSTALL_DIR) $(LINK_NAME)
