require 'gui_pointer_behavior', 'gui_object', 'gui_box', 'gui_list', 'gui_list_with_controls', 'gui_grid', 'gui_message_bar', 'gui_beat_monitor', 'gui_button', 'gui_float', 'gui_toggle', 'gui_curve', 'gui_curve_increasing', 'gui_theme', 'gui_integer', 'gui_select', 'gui_actor', 'gui_event', 'gui_variable', 'gui_engine_button', 'gui_engine_slider', 'gui_radio_buttons', 'gui_object_renderer'
require 'gui-ruby/fonts/bitmap-font'

# Addons to existing objects
load_directory(Dir.pwd + '/gui-ruby/addons/', '**.rb')

require 'gui_preferences_box'
require 'gui_user_object_editor'
require 'gui_add_window'

class GuiDefault < GuiBox
	pipe [:positive_message, :negative_message], :message_bar

	ACTOR_MODE, DIRECTOR_MODE, OUTPUT_MODE = 1, 2, 3

	MENU_BUTTON						= ''
	SAVE_BUTTON						= ''

	EVENTS_BUTTON					= 'Keyboard / F1'
	VARIABLES_BUTTON			= 'Keyboard / F2'

	ACTORS_BUTTON					= 'Keyboard / F8'
	#THEMES_BUTTON					= 'Keyboard / F5'
	#CURVES_BUTTON					= 'Keyboard / F6'
	PREFERENCES_BUTTON		= 'Keyboard / F12'

	callback :keypress

	def initialize
		super
		create!
	end

	def reload_notify
		clear!
		create!
	end

	#
	# Building the GUI
	#
	# Minimal start for a new object: self << GuiObject.new.set(:scale_x => 0.1, :scale_y => 0.1)
	def create!
		@project_drawer = GuiObject.new.set(:scale_x => 0.1, :scale_y => 0.08, :offset_x => -0.5, :offset_y => 0.5-0.04)
#		@project_drawer << (@save_button = GuiButton.new.set(:hotkey => SAVE_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => -0.5, :offset_y => 0.50, :background_image => $engine.load_image('images/buttons/menu.png')))

		# Actors
		self << (@actors_list = GuiListWithControls.new($engine.project.actors).set(:scroll_wrap => true, :scale_x => 0.12, :scale_y => 0.8, :offset_x => 0.44, :offset_y => 0.0, :hidden => true, :spacing_y => -1.0))
		self << (@actors_button = GuiButton.new.set(:hotkey => ACTORS_BUTTON, :scale_x => -0.04, :scale_y => -0.06, :offset_x => 0.48, :offset_y => -0.47, :background_image => $engine.load_image('images/corner.png')))
		@actors_button.on_clicked { toggle_actors_list! }

		# Variables
		self << (@variables_list = GuiListWithControls.new($engine.project.variables).set(:scale_x => 0.12, :scale_y => 0.45, :offset_y => -0.22, :item_aspect_ratio => 3.2, :hidden => true, :spacing_y => -1.0))
#		self << (@variable_button = GuiButton.new.set(:hotkey => VARIABLES_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => -0.42, :offset_y => -0.50, :background_image => $engine.load_image('images/buttons/menu.png')))
#		@variable_button.on_clicked { toggle_variables_list! }

		# Events
		self << (@events_list = GuiListWithControls.new($engine.project.events).set(:scale_x => 0.12, :scale_y => 0.45, :offset_y => 0.23, :item_aspect_ratio => 3.2, :hidden => true, :spacing_y => -1.0))
		self << (@event_button = GuiButton.new.set(:hotkey => EVENTS_BUTTON, :scale_x => 0.04, :scale_y => -0.06, :offset_x => -0.48, :offset_y => -0.47, :background_image => $engine.load_image('images/corner.png')))
		@event_button.on_clicked { toggle_events_list! ; toggle_variables_list! }

#		self << (@themes_list = GuiListWithControls.new($engine.project.themes).set(:scale_x => 0.08, :scale_y => 0.5, :offset_x => -0.11, :offset_y => 0.5, :item_aspect_ratio => 1.6, :hidden => true, :spacing_y => -1.0))
#		self << (@theme_button = GuiButton.new.set(:hotkey => THEMES_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => -0.11, :offset_y => 0.5 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
#		@theme_button.on_clicked { toggle_themes_list! }
#		self << (@curves_list = GuiListWithControls.new($engine.project.curves).set(:scale_x => 0.08, :scale_y => 0.5, :offset_x => 0.06, :offset_y => 0.5, :item_aspect_ratio => 1.6, :hidden => true, :spacing_y => -1.0))
#		self << (@curve_button = GuiButton.new.set(:hotkey => CURVES_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.06, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
#		@curve_button.on_clicked { toggle_curves_list! }

		# Main Menu button
		self << (@project_menu_button = GuiButton.new.set(:hotkey => MENU_BUTTON, :scale_x => 0.04, :scale_y => 0.06, :offset_x => -0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png')))
		@project_menu_button.on_clicked { show_project_menu }

		# Director Button
		self << (@directors_button = GuiButton.new.set(:hotkey => MENU_BUTTON, :scale_x => -0.04, :scale_y => 0.06, :offset_x => 0.48, :offset_y => 0.47, :background_image => $engine.load_image('images/corner.png')))

		# Message Bar
		self << (@message_bar = GuiMessageBar.new.set(:offset_x => 0.02, :offset_y => 0.5 - 0.05, :scale_x => 0.32, :scale_y => 0.05))

		# Beat Monitor
		self << (@beat_monitor = GuiBeatMonitor.new(beats_per_measure=4).set(:offset_y => 0.49, :scale_x => 0.12, :scale_y => 0.02, :spacing_x => 1.0))

		# Preferences Box
		#self << (@preferences_box = GuiPreferencesBox.new.build.set(:scale_x => 0.22, :scale_y => 0.4, :offset_x => 0.4, :offset_y => -0.3, :opacity => 0.0, :hidden => true))
		#self << (@preferences_button = GuiButton.new.set(:hotkey => PREFERENCES_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.50, :offset_y => -0.50, :color => [0.5,1.0,0.5,1.0], :background_image => $engine.load_image('images/buttons/menu.png')))
		#@preferences_button.on_clicked { toggle_preferences_box! }

		# Radio buttons for @mode		TODO: add director view
		self << GuiRadioButtons.new(self, :mode, [ACTOR_MODE, OUTPUT_MODE]).set(:offset_x => 0.35, :offset_y => 0.485, :scale_x => 0.06, :scale_y => 0.03, :spacing_x => 1.0)

		# Defaults
		@user_object_editors = {}
		@chosen_actor = nil
		self.mode = OUTPUT_MODE
	end

	def show_project_menu
		self << bg=GuiObject.new.set(:color => [0,0,0], :opacity => 0.0).animate({:opacity => 0.8}, duration=0.2)
		self << menu=GuiObject.new.set(:scale_x => 0.0, :scale_y => 0.6).animate({:scale_x => 0.3, :scale_y => 0.65}, duration=0.1)
		#bg.on_clicked { bg.remove_from_parent! }
	end

	def mode=(mode)
		return if mode == @mode
		@mode = mode
		after_mode_change
	end

	def after_mode_change
		case @mode
		when ACTOR_MODE
		when DIRECTOR_MODE
		when OUTPUT_MODE
		end
	end

	def render
		case @mode
		when ACTOR_MODE
			@chosen_actor.render! if @chosen_actor
		when DIRECTOR_MODE
			# none yet ...
		when OUTPUT_MODE
			yield
		end
	end

	def gui_render!
		with_scale(($env[:enter] + $env[:exit]).scale(1.5, 1.0)) {
			with_alpha(($env[:enter] + $env[:exit]).scale(0.0, 1.0)) {
				super
			}
		}
	end

	def raw_keyboard_input(value)
		handle_keypress(value) if process_keypress?(value)
	end

	def process_keypress?(value)
		true		# TODO: whitelist
	end

	#
	# Keyboard grabbing
	#
	def grab_keyboard(&proc)
		@keyboard_grab_proc = proc
	end

	def handle_keypress(value)
		@keyboard_grab_proc = nil if @keyboard_grab_proc && @keyboard_grab_proc.call(value) == false
	end

	def toggle_preferences_box!
		if @preferences_box.hidden?		# TODO: this is not a good way to toggle
			@preferences_box.set(:hidden => false, :opacity => 0.0).animate({:opacity => 1.0, :offset_x => 0.38, :offset_y => -0.3}, duration=0.2)
		else
			@preferences_box.animate({:opacity => 0.0, :offset_x => 0.6, :offset_y => -0.6}, duration=0.25) { @preferences_box.set_hidden(true) }
		end
	end

	def toggle_actors_list!
		if @actors_list.hidden?
			show_actors_list!
		else
			close_actors_list!
		end
	end
	def show_actors_list! ; @actors_list.set(:hidden => false, :opacity => 0.0).animate({:opacity => 1.0}, duration=0.2) ; end
	def close_actors_list! ; @actors_list.animate(:opacity, 0.0, duration=0.25) { @actors_list.set_hidden(true) } ; end

=begin
	def toggle_curves_list!
		if @curves_list.hidden?
			@curves_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
		else
			@curves_list.animate(:offset_y, 0.5, duration=0.25) { @curves_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
		end
	end

	def toggle_themes_list!
		if @themes_list.hidden?
			@themes_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
		else
			@themes_list.animate(:offset_y, 0.5, duration=0.25) { @themes_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
		end
	end
=end

	def toggle_variables_list!
		if @variables_list.hidden?
			@variables_list.set(:hidden => false, :offset_x => -0.6, :opacity => 0.0).animate({:offset_x => -0.44, :opacity => 1.0}, duration=0.2)
		else
			@variables_list.animate(:offset_x, -0.6, duration=0.25) { @variables_list.set_hidden(true) }
		end
	end

	def toggle_events_list!
		if @events_list.hidden?
			@events_list.set(:hidden => false, :offset_x => -0.6, :opacity => 0.0).animate({:offset_x => -0.44, :opacity => 1.0}, duration=0.2)
		else
			@events_list.animate({:offset_x => -0.6, :opacity => 0.0}, duration=0.25) { @events_list.set_hidden(true) }
		end
	end

	def build_editor_for(user_object, options)
		pointer = options[:pointer]
		editor = @user_object_editors[user_object]

		if editor && !editor.hidden?
			# was already visible... ...hide self towards click spot
			self.bring_to_top(editor)
			editor.animate({:offset_x => pointer.x, :offset_y => pointer.y, :scale_x => 0.0, :scale_y => 0.0, :opacity => 0.2}, duration=0.2) {
				editor.remove_from_parent!		# trashed forever! (no cache)
				@user_object_editors.delete(user_object)
			}
			return
		else
			if user_object.is_a? ParentUserObject
				# Auto-switch to actor view
				if user_object.is_a? Actor
					@mode = ACTOR_MODE		# TODO: make this an option?
					@chosen_actor = user_object
					close_actors_list!		# TODO: make this an option?
				elsif user_object.is_a? Director
					# TODO
				end

				clear_editors!		# only support one for now

				editor = create_user_object_editor_for_pointer(user_object, pointer, options)
				@user_object_editors[user_object] = editor
				self << editor

				return editor
			else
				# tell editor its child was clicked (this is needed due to non-propagation of click messages: the user object gets notified, it tells us)
				parent = @user_object_editors.keys.find { |uo| uo.effects.include? user_object }		# TODO: hacking around children not knowing their parents for easier puppetry
				parent.on_child_user_object_selected(user_object) if parent		# NOTE: can't click a child if parent is not visible, but the 'if' doesn't hurt
				return
			end
		end
	end

	def create_user_object_editor_for_pointer(user_object, pointer, options)
		GuiUserObjectEditor.new(user_object, {:scale_x => 0.3, :scale_y => 0.05}.merge(options))
			.set({:offset_x => pointer.x, :offset_y => pointer.y, :opacity => 0.0, :scale_x => 0.0, :scale_y => 0.0, :hidden => false})
			.animate({:offset_x => 0.0, :offset_y => -0.25, :scale_x => 0.65, :scale_y => 0.5, :opacity => 1.0}, duration=0.2)
	end

	def clear_editors!
		@user_object_editors.each { |user_object, editor|
			editor.animate({:offset_y => editor.offset_y - 0.25, :scale_x => 0.4, :scale_y => 0.1, :opacity => 0.2}, duration=0.3) {
				editor.remove_from_parent!		# trashed forever! (no cache)
			}
		}
		@user_object_editors.clear
	end

	def pointer_click_on_nothing(pointer)
		if @preferences_box && !@preferences_box.hidden?
			toggle_preferences_box!

		#elsif !@user_object_editors.empty?
		#	clear_editors!

		elsif @actors_list && !@actors_list.hidden?
			toggle_actors_list!

		elsif @themes_list && !@themes_list.hidden?
			toggle_themes_list!

		elsif @curves_list && !@curves_list.hidden?
			toggle_curves_list!

		elsif @variables_list && !@variables_list.hidden?
			toggle_variables_list!

		elsif @events_list && !@events_list.hidden?
			toggle_events_list!

		else
			# TODO: close editor interface?
		end
	end
end
