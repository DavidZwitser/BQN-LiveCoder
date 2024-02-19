TextEditor ⇐ {ch‿skip_chars:
	# ch example: {cursor‿enter‿select ⇐ '_'‿'⋄'‿'_'}
	# skip_chars example: "._"∾@+(32⊸+∾⊢)65↓↕91

	# Type stuff
	Type ⇐ {
		char𝕊t‿c: ⟨nt← char⊸∾⌾(c⊸⌽) t ⋄ 1‿0 Move nt‿c ⟩
	}
	Remove ⇐ {
		amount𝕊t‿c: {0≤c-amount ? ⟨amount⊸↓⌾((c-amount)⊸⌽) t ⋄ (-amount)‿0 Move t‿c⟩ ; t‿c }
	}

	Tab ⇐ (@+9)⊸Type
	Enter ⇐ ch.enter⊸Type

	AddLine ⇐ { line𝕊t‿c:
		c ↩ t XYCursor˜ end←0‿1 + 0‿1 × CursorXY t‿c
		⟨ ⊑ t‿c Type´ ⌽∾⟜ch.enter line ⋄ end XYCursor t⟩
	}
	RemoveLine ⇐ { 𝕊t‿c:
		⟨((((LineStart 𝕩)↑t) ∾ (1+LineEnd 𝕩)↓t)) ⋄ c⟩
	}

	# Swap Lines and Chars
	SwapR ← {⌽⌾(2⊸↑𝕨⊸↓)𝕩}
	SwapL ← {⌽⌾(¯2⊸↑(𝕨+1)⊸↑)𝕩}
	Swap ⇐ {
		1‿0𝕊t‿c: {(c+1)<≠t ? ⟨c SwapR t ⋄ 1‿0 Move t‿c⟩ ; t‿c };
	   ¯1‿0𝕊t‿c: {((c-1)≥0)∧(c)<≠t ? ⟨c SwapL t ⋄ ¯1‿0 Move t‿c⟩ ; t‿c };
		0‿y𝕊t‿c:
			cx‿cy ← CursorXY t‿c ⋄ lines ← ch.enter Split t
			{(≥⟜0 ∧ <⟜(≠lines)) cy+y ? # Does the target line exist?
				new_t ← ∾∾⟜ch.enter¨ (y≡1)◶⟨cy⊸SwapL, cy⊸SwapR⟩ lines
				⟨new_t ⋄ cx‿(cy+y) XYCursor new_t⟩
			; t‿c }
	}

	# Scope cursor to interesting places
	Scope ⇐ { # Returns the distance to the target
		1𝕊t‿c: -⟜c (0<≠)◶⟨0,{c+1+⊑𝕩}⟩ /¬ ∊⟜skip_chars (c+1)↓t ;
	   ¯1𝕊t‿c: -⟜c {(0<≠)◶⟨0,{⊑⌽𝕩}⟩ /¬ ∊⟜skip_chars 𝕩↑t} c
	}

	# Move to one of the outer bounds of the text
	Bounds ⇐ { # Returns the distance to the target
		1‿0𝕊t‿c: -⟜c LineEnd 𝕩;
	   ¯1‿0𝕊t‿c: -⟜c LineStart 𝕩;
		0‿y𝕊t‿c: -⟜c y×≠t
	}

	# Move the cursor normally over the screen
	Move ⇐ {
		x‿0𝕊t‿c: c (0⊸⌈·(≠t)⊸⌊+) x;
		0‿y𝕊t‿c: t XYCursor˜ +⟜0‿y CursorXY t‿c
	}

	# Some functions to get and calculate cursor stuff
	Split ⇐ (⊢-˜+`×¬)∘=⊔⊢ # (from bqncrate) split string into substrings on a char
	CursorXY ⇐ {𝕊t‿c:	# From long line space to splitted space
		trl_sum ← +´ trl←ch.enter=c↑t
		x ← {0≢trl_sum ? -⟜1 ≠ {⊑⌽/𝕩}⊸↓ trl ; c }
		x‿trl_sum
	}

	CleanPick ← (0⊸⌈ ⌊⟜(-⟜1≠))⊑⊢
	XYCursor ⇐ {x‿y𝕊text: # From splitted space to long line space
		⊑/'⍎'=∾ '⍎'⌾(x⊸CleanPick y⊸CleanPick) ∾⟜ch.enter¨ ch.enter Split text
		# Hilarious approach I know. Scared sombody will use ⍕ in their code
	}
	LineStart 	← {𝕊t‿c: 0≢+´trl←ch.enter=c↑t ? 1+⊑⌽/trl ; 0} # index of start of current line
	LineEnd 	← {𝕊t‿c: {0≢+´entrs ← ((>⟜(c-1)↕∘≠) × ch.enter⊸=) t ? ⊑/entrs ; ≠t}} 	# index of end of current line
	Line 		⇐ {𝕊t‿c: (LineEnd nt‿0) ↑ nt←(LineStart 𝕩) ↓ t } # chars in current line
	LineLength 	← LineEnd - LineStart					   # length of current line
}
