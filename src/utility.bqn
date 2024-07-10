# A "closured namespace" that deals with replicating the repeat behaviour keyboards excibit when holding a key
RepeatKey ⇐ {𝕊repeat_delay‿repeat_interval:
	⟨was_down, down_time, last_repeat⟩ ← 3⥊0
	last_time ← •MonoTime@

	Do ⇐ {𝕊down:
		should_type ← 0 ⋄ delta_time ← (•MonoTime@) - last_time
		{down ? down_time +↩ delta_time ; down_time ↩ 0}

		# First press
		{down ∧ ¬was_down ? should_type ↩ 1 ; 0}

		# Repeat
		{(down_time > repeat_delay) ∧ ((•MonoTime@) - last_repeat) > repeat_interval ?
			last_repeat ↩ •MonoTime@, should_type ↩ 1 ; @
		}

		was_down ↩ down ⋄ last_time ↩ •MonoTime@
		should_type
	}
}

ErrorSafe ⇐ {𝕊msg:
	par_cache←@
	res_cache←@
	_try ⇐ {Func _𝕣 ⟨passed_err⋄pars⟩:
		new_err←@ ⋄ res←Func⎊{𝕊:new_err↩ ∾⟜(•Fmt pars) msg∾•CurrentError@} pars
		error ← {passed_err≢@?passed_err;new_err}
		{new_err≢@ ?
			{par_cache≡@?
				⟨error⋄@⟩ ;
				⟨error⋄ Func⎊{res_cache≢@?res_cache;@} par_cache⟩
			}
			; par_cache↩pars ⋄ ⟨error⋄res_cache↩res⟩
		}
	}
}
