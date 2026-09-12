#!/bin/bash

# ==============================================================================
# GLOBAL & REUSABLE CONFIG
# ==============================================================================
export GUM_PRIMARY_COLOR="{{colors.primary.default.hex}}"
export GUM_SECONDARY_COLOR="{{colors.secondary.default.hex}}"
export GUM_TERTIARY_COLOR="{{colors.tertiary.default.hex}}"
export GUM_BACKGROUND_COLOR="{{colors.background.default.hex}}"
export GUM_FOREGROUND_COLOR="{{colors.on_surface.default.hex}}"
export GUM_MUTED_COLOR="{{colors.outline.default.hex}}"
export GUM_ERROR_COLOR="{{colors.error.default.hex}}"

# ==============================================================================
# 1. CHOOSE
# ==============================================================================
export GUM_CHOOSE_PADDING="1 2"                  
export GUM_CHOOSE_HEADER_FOREGROUND="$GUM_TERTIARY_COLOR"    
export GUM_CHOOSE_HEADER_BACKGROUND=""           
export GUM_CHOOSE_CURSOR_FOREGROUND="$GUM_PRIMARY_COLOR"    
export GUM_CHOOSE_CURSOR_BACKGROUND=""           
export GUM_CHOOSE_ITEM_FOREGROUND="$GUM_FOREGROUND_COLOR"      
export GUM_CHOOSE_ITEM_BACKGROUND=""           
export GUM_CHOOSE_SELECTED_FOREGROUND="$GUM_PRIMARY_COLOR"  
export GUM_CHOOSE_SELECTED_BACKGROUND=""         
export GUM_CHOOSE_TIMEOUT_FOREGROUND="$GUM_ERROR_COLOR"
export GUM_CHOOSE_TIMEOUT_BACKGROUND=""

# ==============================================================================
# 2. CONFIRM
# ==============================================================================
export GUM_CONFIRM_PROMPT_FOREGROUND="$GUM_TERTIARY_COLOR"
export GUM_CONFIRM_PROMPT_BACKGROUND=""
export GUM_CONFIRM_SELECTED_FOREGROUND="$GUM_BACKGROUND_COLOR"
export GUM_CONFIRM_SELECTED_BACKGROUND="$GUM_PRIMARY_COLOR"
export GUM_CONFIRM_UNSELECTED_FOREGROUND="$GUM_FOREGROUND_COLOR"
export GUM_CONFIRM_UNSELECTED_BACKGROUND=""

# ==============================================================================
# 3. FILE
# ==============================================================================
export GUM_FILE_CURSOR_FOREGROUND="$GUM_PRIMARY_COLOR"
export GUM_FILE_HEADER_FOREGROUND="$GUM_TERTIARY_COLOR"
export GUM_FILE_FILE_FOREGROUND="$GUM_FOREGROUND_COLOR"
export GUM_FILE_DIRECTORY_FOREGROUND="$GUM_SECONDARY_COLOR"
export GUM_FILE_SYMLINK_FOREGROUND="{{colors.inverse_primary.default.hex}}"

# ==============================================================================
# 4. FILTER
# ==============================================================================
export GUM_FILTER_INDICATOR_FOREGROUND="$GUM_PRIMARY_COLOR"
export GUM_FILTER_TEXT_FOREGROUND="$GUM_FOREGROUND_COLOR"
export GUM_FILTER_MATCH_FOREGROUND="$GUM_TERTIARY_COLOR"
export GUM_FILTER_HEADER_FOREGROUND="$GUM_TERTIARY_COLOR"
export GUM_FILTER_HEADER_BACKGROUND=""
export GUM_FILTER_CURSOR_FOREGROUND="$GUM_PRIMARY_COLOR"
export GUM_FILTER_CURSOR_BACKGROUND=""
export GUM_FILTER_ITEM_FOREGROUND="$GUM_FOREGROUND_COLOR"
export GUM_FILTER_ITEM_BACKGROUND=""
export GUM_FILTER_SELECTED_FOREGROUND="$GUM_PRIMARY_COLOR"
export GUM_FILTER_SELECTED_BACKGROUND=""

# ==============================================================================
# 5. INPUT
# ==============================================================================
export GUM_INPUT_PROMPT_FOREGROUND="$GUM_PRIMARY_COLOR"
export GUM_INPUT_PROMPT_BACKGROUND=""
export GUM_INPUT_PLACEHOLDER_FOREGROUND="$GUM_MUTED_COLOR"
export GUM_INPUT_PLACEHOLDER_BACKGROUND=""
export GUM_INPUT_CURSOR_FOREGROUND="$GUM_PRIMARY_COLOR"
export GUM_INPUT_CURSOR_BACKGROUND=""
export GUM_INPUT_VALUE_FOREGROUND="$GUM_FOREGROUND_COLOR"
export GUM_INPUT_VALUE_BACKGROUND=""

# ==============================================================================
# 6. PAGER
# ==============================================================================
export GUM_PAGER_FOREGROUND="$GUM_FOREGROUND_COLOR"
export GUM_PAGER_BACKGROUND=""
export GUM_PAGER_HELP_FOREGROUND="$GUM_MUTED_COLOR"
export GUM_PAGER_HELP_BACKGROUND=""
export GUM_PAGER_LINE_NUMBER_FOREGROUND="$GUM_MUTED_COLOR"

# ==============================================================================
# 7. SPIN
# ==============================================================================
export GUM_SPIN_SPINNER_FOREGROUND="$GUM_PRIMARY_COLOR"
export GUM_SPIN_SPINNER_BACKGROUND=""
export GUM_SPIN_TITLE_FOREGROUND="$GUM_FOREGROUND_COLOR"
export GUM_SPIN_TITLE_BACKGROUND=""

# ==============================================================================
# 8. WRITE
# ==============================================================================
export GUM_WRITE_PROMPT_FOREGROUND="$GUM_PRIMARY_COLOR"
export GUM_WRITE_PROMPT_BACKGROUND=""
export GUM_WRITE_PLACEHOLDER_FOREGROUND="$GUM_MUTED_COLOR"
export GUM_WRITE_PLACEHOLDER_BACKGROUND=""
export GUM_WRITE_CURSOR_FOREGROUND="$GUM_PRIMARY_COLOR"
export GUM_WRITE_CURSOR_BACKGROUND=""
export GUM_WRITE_VALUE_FOREGROUND="$GUM_FOREGROUND_COLOR"
export GUM_WRITE_VALUE_BACKGROUND=""
export GUM_WRITE_BASE_FOREGROUND="$GUM_FOREGROUND_COLOR"

# ==============================================================================
# 9. TABLE
# ==============================================================================
export GUM_TABLE_CELL_FOREGROUND="$GUM_FOREGROUND_COLOR"
export GUM_TABLE_CELL_BACKGROUND=""
export GUM_TABLE_HEADER_FOREGROUND="$GUM_TERTIARY_COLOR"
export GUM_TABLE_HEADER_BACKGROUND=""
export GUM_TABLE_SELECTED_FOREGROUND="$GUM_BACKGROUND_COLOR"
export GUM_TABLE_SELECTED_BACKGROUND="$GUM_PRIMARY_COLOR"

# ==============================================================================
# 10. LOG
# ==============================================================================
export GUM_LOG_LEVEL_DEBUG_FOREGROUND="$GUM_MUTED_COLOR"
export GUM_LOG_LEVEL_INFO_FOREGROUND="$GUM_PRIMARY_COLOR"
export GUM_LOG_LEVEL_WARN_FOREGROUND="$GUM_SECONDARY_COLOR"
export GUM_LOG_LEVEL_ERROR_FOREGROUND="$GUM_ERROR_COLOR"
export GUM_LOG_KEY_FOREGROUND="$GUM_TERTIARY_COLOR"
export GUM_LOG_VALUE_FOREGROUND="$GUM_FOREGROUND_COLOR"
