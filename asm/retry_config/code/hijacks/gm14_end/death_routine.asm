;=====================================
; death_sfx routine
;
; Handles death music/sfx when dying, death counter and other stuff.
; This runs just before AMK, so we can kill the death song before it starts.
;=====================================
death_routine:
    ; Update the death counter.
    ldx #$04
-   lda !ram_death_counter,x : inc : sta !ram_death_counter,x
    cmp #10 : bcc +
    lda #$00 : sta !ram_death_counter,x
    dex : bpl -
+
    ; Call the custom death routine.
    php : phb
    jsr extra_death
    plb : plp

    ; If the music is sped up, play the death song to make it normal again.
    lda !ram_hurry_up : bne .return

if !lose_lives
    ; If not infinite lives and they're over, skip retry as we're about to game over.
    lda $0DBE|!addr : beq .return
endif

    ; Check if we have to disable the death music.
    jsr shared_get_prompt_type
    cmp #$02 : bcc .return
    cmp #$04 : bcs .return

.no_death_song:
    ; Don't play the death song.
    stz $1DFB|!addr

    ; Play the death SFX.
    lda.b #!death_sfx : sta !death_sfx_addr

    ; Undo the $0DDA change.
    ; This ensures the song won't be reloaded if it's the same after respawning.
    lda !ram_music_backup : sta $0DDA|!addr

.return:
    rts