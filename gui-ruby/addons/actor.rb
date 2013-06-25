class Actor
	ACTOR_COLOR = [1,1,1,1]

	def gui_render!
		# Checkerboard background
		$gui.actor_view_background_image.using {
			unit_square
		}

		# Highlighting (TODO: better solution)
		gui_render_background

		# Render as cached image
		with_color(ACTOR_COLOR) {
			with_image {
				unit_square
			}
		}

		# Label
		if pointer_hovering?
			with_translation(-0.35, -0.35) {
				with_scale(0.25, 0.25) {
					gui_render_label
				}
			}
		end
	end

	def update_offscreen_buffer?
		pointer_hovering?
	end

	#
	# ...
	#
	def init_offscreen_buffer
		return if @offscreen_buffer
		@offscreen_buffer = get_offscreen_buffer(framebuffer_image_size)
		update_offscreen_buffer!
	end

	def framebuffer_image_size
		:medium		# see drawing_framebuffer_objects.rb
	end

	def with_image
		init_offscreen_buffer
		if @offscreen_buffer
			update_offscreen_buffer! if update_offscreen_buffer?
			@offscreen_buffer.with_image {
				yield
			}
		end
	end

	def update_offscreen_buffer!
		@offscreen_buffer.using {
			render!
		}
	end
end
