# start clock then tick at the start of every frame to get accurate clock.delta and clock.time
StartClock ← {𝕊@:
  startTime ⇐ •MonoTime@
  Time  ⇐ {𝕊:startTime-˜•Monotime@}
}
clock ← StartClock@

LFO ⇐ {
	𝕊step‿size: ×⟜size ÷⟜2 •math.Sin ×⟜(clock.Time⟨⟩) ×⟜step π÷2;
	𝕊step: 			  ÷⟜2 •math.Sin ×⟜(clock.Time⟨⟩) ×⟜step π÷2
}

Tile ⇐ {𝕊 size‿amount:
	amount |↩
	el_count ← {1<≠amount ? amount ;
		short_axis_amount ← amount×÷´∧size
		⌽⍟(>´size) short_axis_amount∾amount
	}
	el_size ← size÷el_count
	∧˘⌾⍉¨ {(el_size × 𝕩) (⊣≍+) el_size}¨ ↕⌈el_count
}

Center ⇐ {ws 𝕊 ell:
	ell_size ← (¯1⊏(¯1‿¯1)⊑ell)-(tl←⊏⊑ell) # bottom_right - top_left
	ell_center ← tl + ell_size÷2
	move_vec ← ≍˜(ws÷2) - ell_center
	{𝕩 + move_vec}¨ ell
}

Square ⇐ {𝕊ell:
	{-´-˝⌽𝕩}⊸{ # Get the diff of the side that is too large (- meaning y is to large + meaning x is too large)
		off←÷⟜2|𝕨 # The amount each corner should move
		(𝕩) + ⌽˘⍟(𝕨<0) [off‿0⋄(-off)‿0] # ⌽˘ if we're dealing with y's
	}¨ ell # First untangeling the shape (fixing top left and top right
}

Scale ⇐ {scale𝕊ell:
	{
		center ← ÷⟜2 +˝ 𝕩
		size ← scale × -˝⌽ 𝕩
		center (-≍+) ÷⟜2 size
	}¨ ell
}

Shape ⇐ {𝕊 shapes‿ellements‿colors:
	{𝕊length: length⊸(|˜⟜≠⊑⊢)¨ ⟨shapes ⋄ ⥊ellements ⋄ colors⟩ }¨ ↕⊑∨≠¨ ⥊¨ 𝕩
}
