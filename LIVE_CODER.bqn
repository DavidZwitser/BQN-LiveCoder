# LINK RAYLIB HERE ↓
⟨color, win⇐window, d⇐draw, key, m⇐mouse, rayffi⟩←r←•Import "../../rayed-bqn/raylib.bqn"
operators ← •Import"./operations.bqn"
⟨TextEditor⟩ ← •Import "./TextEditor.bqn"
⟨RepeatKey, ErrorSafe⟩ ← •Import "./Utility.bqn"

theme  ← ⟨
	86‿156‿214	⋈"+-×÷⋆√⌊⌈∧∨¬|≤<≥>=≠≡≢⊣⊢⥊∾≍⋈↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!𝔽𝔾𝕊𝕎𝕏"
	79‿201‿176	⋈"𝕗𝕘𝕤𝕨"
	204‿204‿204	⋈"˙˜˘¨⌜⁼`←⇐↩.;:?•𝕣⋄,←⇐↩.;:?•𝕣⋄,‿·"
	197‿134‿192	⋈"∘○⊸⟜⌾⊘◶⎊⎉⚇⍟"
	255‿215‿0	⋈"{}⟨⟩()[]"
	181‿206‿168	⋈"¯π1234567890"
	106‿153‿85	⋈"#​"
⟩
Col ← {𝕊char: 0<≠indx←/{∨´char=1⊑𝕩}¨ theme ? ⊑indx⊑theme ; 79‿201‿176 }

SHOW ← {x←•Show𝕩, •term.Flush@, x}
DSHOW ← {x←•Show 𝕩, •Show 𝕨, •term.Flush@, x}

curve ← {
	# points DrawFunction amplitude‿frequency‿phase_shift
	_GenNormalized ⇐ {points Fn _𝕣 amp‿freq‿ph_wh: # A normalised list of coords given a function
		∾⟜{amp× Fn freq× ph_wh+ 𝕩}¨ ÷⟜points ↕points+1
	}
	ReRange ⇐ {⟨from_s⋄from_e⟩‿⟨to_s⋄to_e⟩𝕊points: # s≡start ⋄ e≡end, only works on y
		0‿(to_s)⊸+¨ 1‿(to_e-to_s)⊸×¨ 1‿(1÷(from_e-from_s))⊸×¨ +⟜0‿from_s¨ points
	}
	Draw ⇐ {[tl⋄br]‿color‿edge_color‿thickness 𝕊 points:
		·‿y←tl ⋄ ·‿h ← tl+br-tl ⋄ c←0
		{	# Folding over each point
			draw_dot ← 10<20|c+↩1 # Simple counter for the dottet lines when out of bounds
			# Do the signs match eachther (it isn't a jump from one side to the other)
			on_edge ← (𝕩 ≡○{×-⟜(h÷2)1⊸⊑𝕩} 𝕨) ∧ (y⊸≡ ∨ h⊸≡) 1⊑𝕨  # Seeing if we have a minned or maxed point (out of bounds)
			(⊢◶⟨ color ⋄ edge_color×draw_dot ⟩ on_edge)‿thickness d.Line 𝕩≍𝕨
			𝕨 # Returning the last point
		}´ (y⊸⌈h⊸⌊)⌾(1⊸⊑)¨ tl⊸+¨ (br-tl)⊸×¨ points ⋄ points
	}

	# Curve genrators
	SIN ⇐ {0.5+ ÷⟜2 •math.Sin 𝕩×2×π}
	SAW ⇐ {|1|𝕩}
	TRI ⇐ {|1-˜2|2×𝕩}
	SQU ⇐ {⌊2|2×𝕩}
}

LFOInterface ← {𝕊:
	# Curve values
	freq ← 1
	phase_shift ← 0
	amp ← 0.4
	offset ← 0.5
	range ← 1

	# Utility values
	last_time ← •MonoTime@
	ws ← ww‿wh ← 400‿400 	# window size ← window_width‿window_height
	m_pos ← m.GetPos@
	val ← 0
	curve_coords ← ⋈0
	window_offset ← -ws×0.5‿¯0.1

	fnc ← ⊑ fncs ← curve.sin‿curve.saw‿curve.tri‿curve.squ
	fnc_name ← ⊑fnc_names ← "SIN"‿"SAW"‿"TRI"‿"SQU"

	Update ⇐ {𝕊 pos:
		x‿y ← pos (10‿10⊸⌈·(ws-10‿10)⊸⌊+)↩ window_offset
		m_x‿m_y←m_pos ⋄ lmx‿lmy ← m_pos - pos # local mouse x ⋄ local mouse y

		delta ← last_time-˜•MonoTime@ ⋄ last_time ↩ •MonoTime@
		# Looping phase_shift one whole loop of the curve
		phase_shift ↩ {phase_shift≥ 1÷freq ? delta ; phase_shift+delta}

		# Changing the function or range
		{𝕊: fnc_name ↩ ⊑fnc_names 1⊸⌽↩ ⋄ fnc ↩ ⊑fncs 1⊸⌽↩ }⍟key.IsPressed key.space
		{0≢v←(××(⌈|)) m.WheelMoved⟨⟩ ? range |∘+↩v;@}

		m_pos ↩ m.GetPos@

		amp ↩ -2× (lmy-(wh÷2)) ÷ wh # amplitude mouse_y from center
		freq ↩ 10000⌊ ww÷lmx # Frequency limited to 10000

		# Calculating points of the curve
		curve_coords ↩ (500⌊|⌊ww×freq) Fnc curve._GenNormalized amp‿freq‿phase_shift
		val ↩ 1⊑⊑curve_coords # The first point in the curve is our value
	}

	GetFormula ⇐ {𝕊: ("("∾(•FMT ÷⟜10⌊10×amp)∾"× "∾(•FMT ÷⟜10⌊10×offset)∾"+ "∾fnc_name∾" time +"∾(•Fmt ÷⟜10⌊10×freq)∾")")}
	Draw ⇐ {𝕊 pos:
		x‿y ← pos (10‿10⊸⌈·(ws-10‿10)⊸⌊+)↩ window_offset

		# The backdrop
		color.black d.Rectangle pos (⊣≍+) ww‿wh

		# Drawing the curve!
		mapped_coords ← ⟨0‿amp ⋄ offset (-≍+) ÷⟜range amp÷2⟩ curve.ReRange curve_coords
		[pos ⋄ pos+ws]‿color.red‿color.gray‿3 curve.Draw mapped_coords

		# {𝕊i: color.gray d.Rectangle (x‿(y+wh×i)) (⊣≍+) ww‿1 }¨ ÷⟜(range÷5)↕⌊range÷5 #SHOW ÷⟜range ↕ |⌈ range
		# {𝕊i: color.gray d.Rectangle (x‿(y+ wh×i )) (⊣≍+) ww‿2 }¨ ⋈offset

		# The number you see in the center
		color.white‿font‿30 d.Text (⌊pos + ÷⟜2 ww‿wh)‿(•FMT ÷⟜100⌊100×val)

		# The circle on the left moving with the curve
		val_y ← (wh÷2)+ y+ wh× val - (amp÷2)
		(⊢◶⟨color.red⋄color.gray⟩ (y⊸>∨(y+wh)⊸<) val_y) d.Ellipse |⌊x‿(y⌈(y+wh)⌊ val_y) (-≍+) 10‿10

		# The formula in the bottom
		color.white‿font‿20 d.Text ((x-ww)‿y+wh+10)‿(GetFormula@)
	}
}

DynamicNums ← {𝕊e‿char_size:
	lfoChooser ← LFOInterface@
	type ← ⊑ nothing‿shift‿lfo ← {𝕊:⇐}¨↕3

	IsNmbr ← {+´˘ 𝕩 =⌜ "¯."∾'0'+↕10}
	GetNmbr ← {𝕊t‿c:
		start ← c - +´∧` IsNmbr ⌽ c ⌽ t # Start index of the number
		length ← +´∧` IsNmbr start ⌽ t # Length of the number
		start‿length
	}

	start‿length ← 0‿0
	m_down_pos ← 0‿0
	down_val ← 0
	m_press ← 0

	Update ⇐ { 𝕊 t‿c:
		m_down ← m.IsButtonDown m.button.left
		m_pos ← m.GetPos@

		{rayffi.IsMouseButtonPressed 0 ?
			type ↩ {key.IsDown key.left_shift ? shift ; key.IsDown key.left_control ? lfo ; nothing};
			m_press ↩ 1
		@}

		{m_down ? m_press ↩ 0 ⋄ type≢nothing ? ⊑IsNmbr ⋈c⊑t ?
			start‿length ↩ GetNmbr t‿c
			# Data that stays consistent during the interaction (that only gets calculated the first frame)
			{m_press ?
				m_down_pos ↩ m_pos
				down_val ↩ •ParseFloat {'¯'≡𝕩?'-';𝕩}¨ length↑start⌽t
			;@}

			# Get the new value
			new_nmbr ← {
				type ≡ shift?
					•FMT ÷⟜10⌈10× down_val+ 0.1× (⊑m_pos) - ⊑m_down_pos
				; type ≡ lfo ?
					•FMT ÷⟜100⌊100× lfoChooser.Update m_down_pos
				; •FMT down_val
			}

			# Replace the number with the new number and move the cursor to the start
			t‿c↩ ⟨{new_nmbr ∾ length↓𝕩}⌾(start⊸⌽) t ⋄ start⟩
			t‿c

		; rayffi.IsMouseButtonReleased 0 ? type ≡ lfo ?
			start‿length ← GetNmbr t‿c
			formula ← lfoChooser.GetFormula@
			⟨{formula ∾ length↓𝕩}⌾(start⊸⌽) t ⋄ start⟩
		; t‿c }
	}

	Draw ⇐ {𝕊t‿c:
		{m.IsButtonDown m.button.left ? type ≡ lfo ?
			lfoChooser.Draw m_down_pos
		;@}
		{(type≡lfo) ∨ type≡shift ?
			xy ← e.CursorXY t‿start
			color.gray d.Rectangle •SHow ⌊(xy×char_size) (⊣≍+) (xy+0‿(length×1⊑char_size)×char_size)
		;@}
	}
}

RaylibTextEditor ← {𝕊 ⟨font ⋄ font_size ⋄ default_text⟩:
	GetCharSize ← 1‿0.5⊸×
	char_size ← GetCharSize font_size

	# The details you can change about the editor
	chars ← {cursor‿enter‿select ⇐ '_'‿(@+10)‿'_'}
	skip_chars ← (@+48+↕10)∾"._"∾@+(32⊸+∾⊢)65↓↕91

	# Our instance of the editor
	e ← TextEditor chars‿skip_chars

	dynNums ← DynamicNums e‿char_size

	# THE local data used to update the editor
	Buffer ← {𝕊 initial‿size:
		buffer←⟨initial⟩ ⋄ forward_buffer←⟨⟩
		Add ⇐ {S: buffer (⋈𝕩)⊸∾ ↩ ⋄ forward_buffer ↩ (⟨⟩) ⋄ { size<≠buffer ? buffer 1⊸↓⌾⌽↩ ; @} }
		Redo ⇐ {𝕊: 0<≠forward_buffer ? buffer ↩ ⋈⊑forward_buffer ⋄ forward_buffer 1⊸↓ ↩ ; @ }
		Undo ⇐ {𝕊: 1<≠buffer ? forward_buffer (⋈⊑buffer)⊸∾↩ ⋄ buffer 1⊸↓↩ ; @}
		Current ⇐ {𝕊: ⊑buffer }
	}
	b ← Buffer ⟨default_text‿0, 200⟩

	# Makking a very hacky tool to instantiates a whole bunch of repeaters. Like a revolver it'll do rounds!
	# I make sure! I use up all my repeaters each frame so the next frame everyone will get back the some one
	RepeatKeys ← {amount𝕊timings: keys ← RepeatKey¨ amount⥊⋈timings, Do ⇐ {𝕊v: keys 1⊸⌽↩, (⊑keys).Do v}}
	buffer_repeats ← 2 RepeatKeys 0.5‿0.05
	Update ⇐ {𝕊:
		{𝕊: char_size ↩ GetCharSize font_size +↩ 0.5  }⍟((key.IsDown key.left_super) ∧ key.IsDown key.equal)@
		{𝕊: char_size ↩ GetCharSize font_size -↩ 0.5 }⍟((key.IsDown key.left_super) ∧ key.IsDown key.minus)@
		update ← 0
		{b.Add𝕩⋄update↩1}⍟(≢⟜last) React last ← b.Current@
		b.Undo⍟(buffer_repeats.Do (1‿0 ≡ key.IsDown¨ key.left_super‿key.left_shift) ∧ key.IsDown key.z)@
		b.Redo⍟(buffer_repeats.Do (∧´ key.IsDown¨ key.left_shift‿key.left_super) ∧ key.IsDown key.z)@
		update
	}
	Output ⇐ {𝕊: Draw b.Current@ }
	Get ⇐ {𝕊: ⊑b.Current@ }

	repeats ← 7 RepeatKeys 0.5‿0.05
	React ← {𝕊 t‿c:
		t‿c dynNums.Update ↩

		# Typing chars!
		t‿c e.Type⍟(@≢⊣)˜ ↩ key.PressedChar @

		# Moving cursor to where you clicked
		{𝕊:c ↩ (⌊(m.GetPos@)÷⌽char_size) e.XYCursor t}⍟rayffi.IsMouseButtonPressed 0

		remove_amount ← |{key.IsDown key.left_alt ? ¯1 e.Scope t‿c ; key.IsDown key.left_super ? ¯1‿0 e.Bounds t‿c ; 1}
		t‿c e.Remove ⍟(repeats.Do key.IsDown key.backspace)˜ ↩ remove_amount
		# t‿c e.Remove ⍟(repeats.Do key.IsDown key.delete)˜ ↩ -remove_amount
		t‿c e.Tab	⍟(repeats.Do key.IsPressed key.tab) ↩
		t‿c e.Enter ⍟(repeats.Do 1‿0 ≡ key.IsDown¨ key.enter‿key.left_super) ↩

		# All the things to do with the arrow keys
		{𝕊direction:
			{(∧´ key.IsDown¨ key.left_alt‿key.left_super) ? t‿c e.Swap˜ ↩ direction
			; (key.IsDown key.left_alt ∧ 0≡⊑direction) ? t‿c e.Swap˜ ↩ direction
			;	direction ×↩ |{key.IsDown key.left_alt ?
					(⊑direction) e.Scope t‿c
				; key.IsDown key.left_super ?
					direction e.Bounds t‿c
				; 1 }
				c↩ t‿c e.Move˜ direction
			}
		}¨ ⊑⟜⟨1‿0 ⋄ 0‿1 ⋄ ¯1‿0 ⋄ 0‿¯1⟩¨ / repeats⊸{𝕨.Do 𝕩}¨ key.IsDown¨ key.right‿key.down‿key.left‿key.up

		# Copy pasta
		(r.clipboard.Set∘e.Line t‿c˙)⍟((key.IsDown key.left_super) ∧ (∨´ key.IsPressed¨ key.c‿key.x))@
		{t‿c e.AddLine˜ ↩ 𝕩}∘r.clipboard.Get⍟((key.IsDown key.left_super) ∧ key.IsPressed key.v)@
		(r.clipboard.Set∘e.Line t‿c˙)⍟((key.IsDown key.left_super) ∧ key.IsPressed key.c)@
		{𝕊: t‿c e.RemoveLine ↩}⍟((key.IsDown key.left_super) ∧ key.IsPressed key.x)@

		("./save.bqn"⊸•file.Chars t˙)⍟((key.IsDown key.left_super) ∧ key.IsPressed key.s)@
		t‿c
	}

	clock ← r.StartClock@
	Draw ← {𝕊t‿c:
		("text is not a string: "⋈t) { 𝕨!1≡≡𝕩 ⋄ 𝕨! ∧´{2≡•Type𝕩}¨𝕩} t
		# Drawing background
		char_size⊸{ch_h‿ch_w𝕊y‿length: (32‿32‿32‿200) d.Rectangle ⟨0⋄y×ch_h⟩ (⊣≍+) ⟨length×ch_w⋄ch_h⟩ }¨ ((↕≠) ∾¨ ≠¨) chars.enter e.Split t
		DrawLines chars.enter e.Split t

		((e.CursorXY t‿c)∾⋈(204‿204‿204‿255))⊸DrawChar⟜chars.cursor⍟(0.2<1|clock.Time⟨⟩)@

		dynNums.Draw t‿c
		# {(𝕩 CursorXY text) DrawChar ch.select}¨⍟(>⟜1≠) ((⊑∧)+(↕·¬´∨)) cursor‿select_start
	}
	DrawLines ← {
		𝕊lines: (↕≠lines) {y𝕊line: (↕≠line) {x𝕊ch: x‿y‿(∾⟜255 Col ch) DrawChar ch}¨ line }¨ lines;
		color𝕊lines: lines ⋄ (↕≠lines) {y𝕊line: (↕≠line) {x𝕊ch: x‿y‿color DrawChar ch}¨ line }¨ lines
	}
	DrawChar ← {x‿y‿color𝕊char: color‿font‿font_size d.Text ⟨⌊⌽(y‿x)×char_size, ⋈char⟩ }
}

font ← @
_Start ← { Update _𝕣 𝕩:
	win.SetSize w_size ← 1200‿1200
	font ↩ r.font.LoadBQN 300 #⋄ win.SetPos ¯2000‿¯900
	editor ← RaylibTextEditor font‿30‿(•file.Chars "./save.bqn")

	Update editor‿⟨@⋄@⟩‿1
}

DressUp ← {𝕊text:
	Replace ← {find‿replace𝕊str: {∨´find⍷str ? ∾{find≡𝕩? replace ; 𝕩}¨ str ; str} }

	# Add flushed show function
	# text ("print_store⇐"""" ⋄ Show ← { print_store ∾⟜('⋄'∾𝕩)↩ }"∾(@+10))⊸∾↩

	# Safe pick
	text '⊑'‿"(|˜⟜≠⊑⊢)"⊸Replace ↩

	# Short hand for random
	text '⍕'‿"•rand.Range "⊸Replace ↩
}

DrawShapes ← {
	𝕊⟨'r' ⋄ data ⋄ c⟩:
		c d.Rectangle ⌊data;
	𝕊⟨'e' ⋄ data ⋄ c⟩:
		c d.Ellipse ⌊data;
	𝕊⟨'t' ⋄ data ⋄ c⟩:˜
		c d.Triangle ⌊data ;
	𝕊⟨'l' ⋄ data ⋄ c⟩:
	@
		# c d.Line ⌊data
}


parse‿call‿get‿draw ← ErrorSafe¨ "Parse: "‿"Call: "‿"Update: "‿"Draw: "
clock ← r.StartClock @

DrawError ← {color.red‿font‿20 d.Text (0‿0.85×win.GetSize@)‿𝕩}
Update ← {𝕊 editor‿code‿changed:
	clock.Tick⟨⟩
	{changed ∨ (key.IsDown key.left_super) ∧ key.IsPressed key.enter ?
		code ↩ ⟨@⋄DressUp editor.Get@⟩
		code •BQN parse._try ↩
		code {𝕏 ⟨color, win.GetSize@, operators, curve⟩} call._try ↩
	; @}

	objs ← {𝕩.Get clock.Time@} get._try code
	err ← DrawShapes¨ draw._try objs
	DrawError⍟(≢⟜@) ⊑err

	changed ↩ editor.Update⟨⟩
	editor.Output⟨⟩

	editor‿code‿changed
} d._withCanvas_ 32‿32‿32‿255

Update •_While_ (¬win.ShouldClose) _Start win._openAs "editor"
