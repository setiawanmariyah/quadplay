;; pyxlscript-mode.el --- Major mode for editing Quadplay PyxLScript. -*- coding: utf-8 -*-

;; Copyright © 2020, by Morgan McGuire

;; Author: Morgan McGuire, https://casual-effects.com
;; URL: TBD
;; Version: 0.0.1
;; Keywords: languages, pyxlscript

;; To use this mode, put the file in your elisp directory. Mine is "~/.emacs.d/lisp"
;; and then add to your .emacs:
;;
;;   (autoload 'pyxlscript-mode "pyxlscript-mode")
;;   (add-to-list 'auto-mode-alist '("\\.pyx\\'" . pyxlscript-mode))


;; See http://ergoemacs.org/emacs/elisp_write_major_mode_index.html
(defvar pyxlscript-mode-syntax-table nil "Syntax table for `pyxlscript-mode'.")

(setq pyxlscript-mode-syntax-table
      (let ( (synTable (make-syntax-table)))
        ;; C and C++ style comments "// …", "/* … */" (based on https://github.com/emacs-mirror/emacs/blob/master/lisp/progmodes/cc-langs.el)
        (modify-syntax-entry ?/  ". 124b" synTable)
        (modify-syntax-entry ?*  ". 23"   synTable)
        (modify-syntax-entry ?\n "> b"  synTable)
        synTable))

(define-derived-mode pyxlscript-mode python-mode "pyxlscript"
  "Major mode to edit Pyxlscript files." :syntax-table pyxlscript-mode-syntax-table

  ;; 3-space indenting
  (setq-local tab-width 3)

  (setq indent-tabs-mode nil)
  (setq python-indent 3)
  (setq python-indent-offset 3)
  (setq python-guess-indent nil)

  ;; For hotkeys
  (setq-local comment-start "/*")
  (setq-local comment-start-skip "/\\*+[ \t]*")
  (setq-local comment-end "*/")
  (setq-local comment-end-skip "[ \t]*\\*+/")

  ;; Syntax highlighting
  (let ((keyword-exp (regexp-opt '("assert" "debug_pause" "debug_print" "debug_watch" "let" "const" "mod" "local" "preserving_transform" "for" "in" "while" "until" "if" "then" "else" "push_mode" "reset_game" "set_mode" "return" "def" "break" "continue" "bitand" "bitnot" "bitor" "bitxor" "bitnot" "bitshl" "bitshr" "because" "quit_game" "launch_game") 'symbols))
        (literal-exp (regexp-opt '("deg" "true" "false" "nan" "SCREEN_SIZE" "pi" "epsilon" "infinity" "nil") 'symbols))
        (event-exp   (regexp-opt '("enter" "leave" "frame") 'symbols))
        (builtin-exp (regexp-opt '("ray_intersect" "draw_bounds" "draw_disk" "reset_clip" "reset_transform" "set_clip" "draw_line" "draw_sprite_corner_rect" "intersect_clip" "draw_point" "draw_corner_rect" "draw_rect" "get_background" "set_background" "text_width" "get_sprite_pixel_color" "draw_sprite" "draw_text" "draw_tri" "draw_poly" "get_transform" "get_clip" "rotation_sign" "sign_nonzero" "set_transform" "xy" "xz_to_xyz" "xy_to_xyz" "xz" "xyz"
                                   "any_button_press" "draw_map" "get_mode" "get_previous_mode" "get_map_pixel_color" "get_map_pixel_color_by_draw_coord" "get_map_sprite" "set_map_sprite" "get_map_sprite_by_draw_coord" "set_map_sprite_by_draw_coord" "unparse" "format_number" "uppercase" "lowercase"
                                   "play_audio_clip" "resume_sound" "stop_sound" "game_frames" "mode_frames" "delay" "sequence" "add_frame_hook" "remove_frame_hook"
                                   "make_entity" "draw_entity" "overlaps" "entity_update_children" "entity_simulate" "split"
                                   "now" "game_frames" "mode_frames" "replace" "find_map_path" "find_path" "join" "entity_apply_force" "entity_apply_impulse"
                                   "gray" "rgb" "rgba" "hsv" "hsva" "last_value" "last_key" "insert" "reverse" "reversed"
                                   "call" "set_post_effects" "get_post_effects" "reset_post_effects" "push_front" "local_time" "device_control" "physics_add_contact_callback" "physics_entity_contacts" "physics_entity_has_contacts" "physics_add_entity" "physics_remove_entity" "physics_remove_all" "physics_attach" "physics_detach" "make_physics" "make_contact_group" "draw_physics" "physics_simulate"
                                   "abs" "acos" "atan" "asin" "sign" "sign_nonzero" "cos" "clamp" "hash" "lerp" "log" "log2" "log10" "loop" "noise" "oscillate" "overlap" "pow" "make_random" "random_sign" "random_integer" "random_within_sphere" "random_on_sphere" "random_within_circle" "random_within_square" "random_on_square" "random_on_circle" "random_direction2D" "random_direction3D" "random_value" "random_gaussian" "random_gaussian2D" "random_truncated_gaussian" "random_truncated_gaussian2D" "random" "ξ" "sgn" "sqrt" "sin" "set_random_seed" "tan"
                                   "concatenate" "extend" "clone" "copy" "draw_previous_mode" "cross" "direction" "dot" "equivalent" "magnitude" "magnitude_squared" "max_component" "min_component" "xy" "xyz"
                                   "fast_remove_key" "find" "keys" "remove_key" "substring" "sort" "resize" "push" "pop" "fast_remove_value" "remove_values" "remove_all" "gamepad_array" "joy" "round" "floor" "ceil"
                                   "debug_print") 'symbols))
        )

    (font-lock-add-keywords
     'pyxlscript-mode

     ;; see:
     ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Search_002dbased-Fontification.html
     `((,keyword-exp 0 font-lock-keyword-face)
       (,builtin-exp 0 font-lock-type-face)
       (,event-exp 0 font-lock-function-name-face)

       ;; Do not treat "pop_mode" or "from" as keywords when on the same line; they are
       ("\\(pop_mode\\).+\\(from\\) " (1 font-lock-function-name-face) (2 font-lock-function-name-face))
       ("pop_mode" . font-lock-keyword-face)

       ;; Only treat "size", "mid", "min", and "max" as a built-in when
       ;; followed by a paren (otherwise it is probably a property)
       ("\\(size\\)(" . (1 font-lock-type-face))
       ("\\(min\\)(" . (1 font-lock-type-face))
       ("\\(max\\)(" . (1 font-lock-type-face))
       ("\\(mid\\)(" . (1 font-lock-type-face))
        
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;; Colors:
       ("#[0-9A-Fa-f]+" . font-lock-constant-face)
       ;; The previous command for color expressions does not catch the # at the start
       ;; of a color if the color begins with a number, so explicitly add it:
       ("#" . font-lock-constant-face)

       ;; Positive and negative numbers, which are broken by the syntax table
       ("[+-]\\([0-9]+\\)"  . (1 font-lock-constant-face))

       (,literal-exp 0 font-lock-constant-face)
       
       ;; elisp regexps don't understand unicode, so we have to explicitly add them here
       ("‖" . font-lock-type-face)
       ("⌊" . font-lock-type-face)
       ("⌋" . font-lock-type-face)
       ("⌈" . font-lock-type-face)
       ("⌉" . font-lock-type-face)
       
       ("∊" . font-lock-keyword-face)
       ("∈" . font-lock-keyword-face)
       
       ("∞" . font-lock-constant-face)
       ("½" . font-lock-constant-face)
       ("⅓" . font-lock-constant-face)
       ("⅔" . font-lock-constant-face)
       ("¼" . font-lock-constant-face)
       ("¾" . font-lock-constant-face)
       ("⅕" . font-lock-constant-face)
       ("⅖" . font-lock-constant-face)
       ("⅗" . font-lock-constant-face)
       ("⅘" . font-lock-constant-face)
       ("⅙" . font-lock-constant-face)
       ("⅐" . font-lock-constant-face)
       ("⅛" . font-lock-constant-face)
       ("⅑" . font-lock-constant-face)
       ("⅒" . font-lock-constant-face)
       ("°" . font-lock-constant-face)
       ("ε" . font-lock-constant-face)
       ("π" . font-lock-constant-face)
       ("∅" . font-lock-constant-face)
       ("∞" . font-lock-constant-face)
       ("⁰" . font-lock-constant-face)
       ("¹" . font-lock-constant-face)
       ("²" . font-lock-constant-face)
       ("³" . font-lock-constant-face)
       ("⁴" . font-lock-constant-face)
       ("⁵" . font-lock-constant-face)
       ("⁶" . font-lock-constant-face)
       ("⁷" . font-lock-constant-face)
       ("⁸" . font-lock-constant-face)
       ("⁹" . font-lock-constant-face)          
       )))
  
  (set-syntax-table pyxlscript-mode-syntax-table)
  )

(provide 'pyxlscript-mode)
