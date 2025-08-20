--- STEAMODDED HEADER
--- MOD_NAME: Forsnaken Mod
--- MOD_ID: forsnakenmod
--- MOD_AUTHOR: [Randmation and Endslayer2411]
--- MOD_DESCRIPTION: Custom jokers including Two Time, Pizza Delivery, Unstable Eye, Raging Pace, Prankster, and Coin Flip
--- MOD_VERSION: 1.0.0

----------------------------------------------
-- Atlas Definitions
----------------------------------------------
SMODS.Atlas{
    key = 'two_time_atlas',
    path = 'twotimeasset.png',
    px = 71,
    py = 95
}

----------------------------------------------
-- Two Time Joker
----------------------------------------------
SMODS.Joker{
    key = 'two_time',
    atlas = 'two_time_atlas',
    pos = {x = 0, y = 0},
    loc_txt = {
        name = 'Two Time',
        text = {
            "Extra chips are stored",
            "in this joker",
            "Sell this joker to decrease",
            "the current blind by the",
            "amount of chips stored",
            "{C:inactive}(Currently: {C:chips}+#1#{C:inactive} Chips)"
        }
    },
    config = { extra = { stored_chips = 0 } },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.stored_chips } }
    end,
    calculate = function(self, card, context)
        -- Check after each hand is played and scored
        if context.joker_main and G.GAME.chips > 0 then
            -- Store current chip count for comparison after scoring
            card.ability.extra.pre_score_chips = G.GAME.chips
        elseif context.after and context.cardarea == G.jokers and not context.blueprint then
            -- After scoring is complete, check if we have excess chips
            if G.GAME.chips > G.GAME.blind.chips then
                local excess = G.GAME.chips - G.GAME.blind.chips
                if excess > 0 then
                    card.ability.extra.stored_chips = (card.ability.extra.stored_chips or 0) + excess
                    return {
                        message = "+" .. tostring(excess) .. " Chips!",
                        colour = G.C.CHIPS
                    }
                end
            end
        elseif context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            -- Alternative: Store excess at end of round if blind was beaten
            if G.GAME.chips > G.GAME.blind.chips and not card.ability.extra.stored_this_round then
                local excess = G.GAME.chips - G.GAME.blind.chips
                if excess > 0 then
                    card.ability.extra.stored_chips = (card.ability.extra.stored_chips or 0) + excess
                    card.ability.extra.stored_this_round = true
                    return {
                        message = "Stored " .. tostring(excess) .. " Chips!",
                        colour = G.C.CHIPS
                    }
                end
            end
        elseif context.setting_blind and not context.blueprint then
            -- Reset the flag for new round
            card.ability.extra.stored_this_round = false
        end
    end,
    calculate = function(self, card, context)
        -- Check after each hand is played and scored
        if context.joker_main and G.GAME.chips > 0 then
            -- Store current chip count for comparison after scoring
            card.ability.extra.pre_score_chips = G.GAME.chips
        elseif context.after and context.cardarea == G.jokers and not context.blueprint then
            -- After scoring is complete, check if we have excess chips
            if G.GAME.chips > G.GAME.blind.chips then
                local excess = G.GAME.chips - G.GAME.blind.chips
                if excess > 0 then
                    card.ability.extra.stored_chips = (card.ability.extra.stored_chips or 0) + excess
                    return {
                        message = "+" .. tostring(excess) .. " Chips!",
                        colour = G.C.CHIPS
                    }
                end
            end
        elseif context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            -- Alternative: Store excess at end of round if blind was beaten
            if G.GAME.chips > G.GAME.blind.chips and not card.ability.extra.stored_this_round then
                local excess = G.GAME.chips - G.GAME.blind.chips
                if excess > 0 then
                    card.ability.extra.stored_chips = (card.ability.extra.stored_chips or 0) + excess
                    card.ability.extra.stored_this_round = true
                    return {
                        message = "Stored " .. tostring(excess) .. " Chips!",
                        colour = G.C.CHIPS
                    }
                end
            end
        elseif context.setting_blind and not context.blueprint then
            -- Reset the flag for new round
            card.ability.extra.stored_this_round = false
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff and card.ability.extra.stored_chips and card.ability.extra.stored_chips > 0 and G.STATE == G.STATES.SELECTING_HAND then
            -- Only reduce blind if we're in the playing phase (not in shop)
            local reduction = card.ability.extra.stored_chips
            
            -- Schedule the blind reduction to happen after the sell
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    if G.GAME.blind and G.GAME.blind.chips then
                        -- Reduce the blind chips
                        local old_chips = G.GAME.blind.chips
                        G.GAME.blind.chips = math.max(1, G.GAME.blind.chips - reduction)
                        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                        
                        -- Force update the blind display
                        G.GAME.blind:set_text()
                        G.GAME.blind:juice_up()
                        
                        -- Update HUD if it exists
                        if G.HUD_blind then
                            G.HUD_blind:recalculate()
                        end
                        
                        -- Show a message about the reduction
                        attention_text({
                            text = "-" .. tostring(reduction) .. " Blind Chips!",
                            scale = 1.3,
                            hold = 2,
                            backdrop_colour = G.C.CHIPS,
                            align = 'cm',
                            offset = {x = 0, y = -2},
                            major = G.play
                        })
                        
                        play_sound('chips2')
                    end
                    return true
                end
            }))
        end
    end
}

----------------------------------------------
-- Pizza Delivery Joker
----------------------------------------------
SMODS.Joker{
    key = 'pizza_delivery',
    loc_txt = {
        name = 'Pizza Delivery',
        text = {
            "Every {C:attention}#2#{} round, multiply",
            "the mult that this joker",
            "gives by {X:mult,C:white}X2{}, then increase",
            "the round requirement by {C:attention}1{}",
            "{C:inactive}(Currently: {C:mult}+#1#{C:inactive} Mult)"
        }
    },
    config = { extra = { mult = 2, rounds_needed = 1, rounds_passed = 0 } },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.rounds_needed } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                card = card
            }
        elseif context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.rounds_passed = card.ability.extra.rounds_passed + 1
            if card.ability.extra.rounds_passed >= card.ability.extra.rounds_needed then
                card.ability.extra.mult = card.ability.extra.mult * 2
                card.ability.extra.rounds_needed = card.ability.extra.rounds_needed + 1
                card.ability.extra.rounds_passed = 0
                return {
                    message = "Upgraded!",
                    colour = G.C.MULT
                }
            end
        end
    end
}

----------------------------------------------
-- Unstable Eye Joker
----------------------------------------------
SMODS.Joker{
    key = 'unstable_eye',
    loc_txt = {
        name = 'Unstable Eye',
        text = {
            "All face down cards are",
            "flipped {C:attention}face-up{}",
            "each hand played"
        }
    },
    config = { extra = {} },
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            -- Store the original draw function if not already stored
            if not G.FUNCS.original_draw_from_deck_to_hand then
                G.FUNCS.original_draw_from_deck_to_hand = G.FUNCS.draw_from_deck_to_hand
            end
            
            -- Override the draw function to always draw face-up
            G.FUNCS.draw_from_deck_to_hand = function(e)
                -- Call original draw function
                if G.FUNCS.original_draw_from_deck_to_hand then
                    G.FUNCS.original_draw_from_deck_to_hand(e)
                end
                
                -- Force all cards in hand to be face-up
                if G.hand and G.hand.cards then
                    for _, c in ipairs(G.hand.cards) do
                        if c.facing == 'back' then
                            c:flip()
                        end
                    end
                end
            end
            
            -- Flip any existing face-down cards
            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if c.facing == 'back' then
                        c:flip()
                    end
                end
            end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff then
            -- Check if there are other unstable eye jokers
            local has_other = false
            for _, joker in ipairs(G.jokers.cards) do
                if joker ~= card and joker.config.center.key == 'j_forsnakenmod_unstable_eye' then
                    has_other = true
                    break
                end
            end
            
            -- Only restore if no other Unstable Eye exists
            if not has_other and G.FUNCS.original_draw_from_deck_to_hand then
                G.FUNCS.draw_from_deck_to_hand = G.FUNCS.original_draw_from_deck_to_hand
                G.FUNCS.original_draw_from_deck_to_hand = nil
            end
        end
    end,
    calculate = function(self, card, context)
        -- Check multiple contexts to flip cards face-up
        if context.before and not context.blueprint then
            -- Before playing a hand, ensure all cards are face-up
            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if c.facing == 'back' then
                        c:flip()
                    end
                end
            end
        elseif context.after and not context.blueprint then
            -- After drawing, ensure all cards are face-up
            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if c.facing == 'back' then
                        c:flip()
                    end
                end
            end
        elseif context.setting_blind and not context.blueprint then
            -- When blind is set, ensure cards are face-up
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    if G.hand and G.hand.cards then
                        for _, c in ipairs(G.hand.cards) do
                            if c.facing == 'back' then
                                c:flip()
                            end
                        end
                    end
                    return true
                end
            }))
        end
    end
}

----------------------------------------------
-- Raging Pace Joker
----------------------------------------------
SMODS.Joker{
    key = 'raging_pace',
    loc_txt = {
        name = 'Raging Pace',
        text = {
            "All boss blinds don't have",
            "an effect until",
            "after first hand played"
        }
    },
    config = { extra = { timer = 20 } },

    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind and G.GAME.blind.boss and not context.blueprint then
            -- Initialize tracking variables
            card.ability.extra.hand_played = false
            card.ability.extra.start_time = love.timer.getTime()
            card.ability.extra.blind_was_disabled = false
            
            -- Schedule the disable to happen after a small delay (like Chicot does)
            G.E_MANAGER:add_event(Event({func = function()
                G.E_MANAGER:add_event(Event({func = function()
                    if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
                        -- Use the same method as Chicot
                        G.GAME.blind:disable()
                        card.ability.extra.blind_was_disabled = true
                        play_sound('timpani')
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Boss Disabled!", colour = G.C.PURPLE})
                    end
                return true end}))
            return true end}))
        elseif context.cardarea == G.jokers and context.before and not context.blueprint then
            -- Mark that a hand has been played but don't re-enable yet
            if card.ability.extra and not card.ability.extra.hand_played then
                card.ability.extra.hand_played = true
            end
        elseif context.after and not context.blueprint then
            -- After hand scoring is complete, re-enable if a hand was played
            if card.ability.extra and card.ability.extra.hand_played and card.ability.extra.blind_was_disabled then
                if G.GAME.blind and G.GAME.blind.boss and G.GAME.blind.disabled then
                    G.GAME.blind.disabled = false
                    G.GAME.blind:set_text() -- Update the blind's display text
                    card.ability.extra.blind_was_disabled = false
                    
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Boss Re-enabled!", colour = G.C.RED})
                end
            end
        elseif context.joker_main then
            -- Check if 20 seconds have passed (only if no hand has been played yet)
            if card.ability.extra and card.ability.extra.start_time and not card.ability.extra.hand_played and card.ability.extra.blind_was_disabled then
                local current_time = love.timer.getTime()
                if current_time - card.ability.extra.start_time >= card.ability.extra.timer then
                    -- Re-enable boss
                    if G.GAME.blind and G.GAME.blind.boss and G.GAME.blind.disabled then
                        G.GAME.blind.disabled = false
                        G.GAME.blind:set_text() -- Update the blind's display text
                        card.ability.extra.blind_was_disabled = false
                        card.ability.extra.hand_played = true -- Prevent re-triggering
                        
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Time's up!", colour = G.C.RED})
                    end
                end
            end
        end
    end
}

----------------------------------------------
-- Prankster Joker
----------------------------------------------
SMODS.Joker{
    key = 'prankster',
    loc_txt = {
        name = 'Prankster',
        text = {
            "Copies the effect of a",
            "{C:attention}random{} joker each hand",
            "{C:inactive}(Currently copying: {C:attention}#1#{C:inactive})"
        }
    },
    config = { extra = { current_copy = "None", copied_joker = nil } },
    rarity = 3,
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local current_copy = "None"
        if card and card.ability and card.ability.extra and card.ability.extra.current_copy then
            current_copy = card.ability.extra.current_copy
        end
        return { vars = { current_copy } }
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Initialize extra if needed
        if not card.ability.extra then
            card.ability.extra = { current_copy = "None", copied_joker = nil }
        end
        
        -- Pick initial joker to copy
        local other_jokers = {}
        for _, joker in ipairs(G.jokers.cards) do
            if joker ~= card then
                local can_blueprint = true
                if joker.config and joker.config.center then
                    if joker.config.center.blueprint_compat == false then
                        can_blueprint = false
                    end
                    -- Prevent copying other Pranksters to avoid stack overflow
                    if joker.config.center.key == 'j_forsnakenmod_prankster' or joker.ability.name == 'Prankster' then
                        can_blueprint = false
                    end
                end
                if can_blueprint then
                    table.insert(other_jokers, joker)
                end
            end
        end
        
        if #other_jokers > 0 then
            card.ability.extra.copied_joker = pseudorandom_element(other_jokers, pseudoseed('prankster'))
            local joker_name = card.ability.extra.copied_joker.ability.name or "Unknown"
            if card.ability.extra.copied_joker.config and card.ability.extra.copied_joker.config.center and card.ability.extra.copied_joker.config.center.name then
                joker_name = card.ability.extra.copied_joker.config.center.name
            end
            card.ability.extra.current_copy = joker_name
        end
    end,
    calculate = function(self, card, context)
        -- Ensure extra is initialized
        if not card.ability.extra then
            card.ability.extra = { current_copy = "None", copied_joker = nil, hand_count = 0 }
        end
        
        -- Pick a new joker at the start of blind
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hand_count = 0
            -- Pick initial joker for this blind
            local other_jokers = {}
            for _, joker in ipairs(G.jokers.cards) do
                -- Prevent copying self and other Pranksters to avoid stack overflow
                local is_prankster = joker.config and joker.config.center and 
                    (joker.config.center.key == 'j_forsnakenmod_prankster' or 
                     joker.ability.name == 'Prankster')
                if joker ~= card and not is_prankster and joker.config.center.blueprint_compat ~= false then
                    table.insert(other_jokers, joker)
                end
            end
            
            if #other_jokers > 0 then
                card.ability.extra.copied_joker = pseudorandom_element(other_jokers, pseudoseed('prankster'))
                card.ability.extra.current_copy = card.ability.extra.copied_joker.ability.name or "Unknown"
            else
                card.ability.extra.copied_joker = nil
                card.ability.extra.current_copy = "None"
            end
        end
        
        -- Pick a new joker after each hand played
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            card.ability.extra.hand_count = (card.ability.extra.hand_count or 0) + 1
            if card.ability.extra.hand_count > 1 then -- After first hand, pick new joker
                local other_jokers = {}
                for _, joker in ipairs(G.jokers.cards) do
                    -- Prevent copying self and other Pranksters to avoid stack overflow
                    local is_prankster = joker.config and joker.config.center and 
                        (joker.config.center.key == 'j_forsnakenmod_prankster' or 
                         joker.ability.name == 'Prankster')
                    if joker ~= card and not is_prankster and joker.config.center.blueprint_compat ~= false then
                        table.insert(other_jokers, joker)
                    end
                end
                
                if #other_jokers > 0 then
                    card.ability.extra.copied_joker = pseudorandom_element(other_jokers, pseudoseed('prankster'..card.ability.extra.hand_count))
                    card.ability.extra.current_copy = card.ability.extra.copied_joker.ability.name or "Unknown"
                else
                    card.ability.extra.copied_joker = nil
                    card.ability.extra.current_copy = "None"
                end
            end
        end
        
        -- Copy the effect if we have a joker selected
        if card.ability.extra.copied_joker then
            -- Check if still exists
            local still_exists = false
            for _, joker in ipairs(G.jokers.cards) do
                if joker == card.ability.extra.copied_joker then
                    still_exists = true
                    break
                end
            end
            
            if still_exists then
                -- Additional safety check to prevent infinite recursion
                local is_copying_prankster = card.ability.extra.copied_joker.config and 
                    card.ability.extra.copied_joker.config.center and 
                    (card.ability.extra.copied_joker.config.center.key == 'j_forsnakenmod_prankster' or
                     card.ability.extra.copied_joker.ability.name == 'Prankster')
                
                if is_copying_prankster then
                    -- Skip copying to prevent stack overflow
                    card.ability.extra.copied_joker = nil
                    card.ability.extra.current_copy = "None"
                    return nil
                end
                
                -- Use Blueprint's method - set context and call calculate_joker
                context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
                context.blueprint_card = context.blueprint_card or card
                if context.blueprint > #G.jokers.cards + 1 then return end
                
                local other_joker_ret = card.ability.extra.copied_joker:calculate_joker(context)
                if other_joker_ret then
                    if other_joker_ret.card then
                        other_joker_ret.card = card
                    end
                    if other_joker_ret.colour then
                        other_joker_ret.colour = G.C.PURPLE
                    end
                    return other_joker_ret
                end
            else
                -- Joker was sold, pick new one
                card.ability.extra.copied_joker = nil
                card.ability.extra.current_copy = "None"
            end
        end
    end
}

----------------------------------------------
-- Noob Joker
----------------------------------------------
SMODS.Joker{
    key = 'noob',
    loc_txt = {
        name = 'Noob',
        text = {
            "Gains {X:mult,C:white}X0.01{} Mult for",
            "every {C:chips}666{} chips scored",
            "at end of round",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)"
        }
    },
    config = { extra = { xmult = 1, chips_to_process = 0 } },
    rarity = 4,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        -- During scoring, apply the multiplier
        if context.joker_main then
            -- Apply the multiplier if we have one
            if card.ability.extra.xmult > 1 then
                return {
                    x_mult = card.ability.extra.xmult,
                    card = card
                }
            end
        -- Use end_of_round like many jokers do for reliable tracking
        elseif context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            -- Check if we beat the blind and have chips to process
            if G.GAME.chips and G.GAME.blind and G.GAME.chips > 0 then
                print("NOOB DEBUG: end_of_round triggered")
                print("  G.GAME.chips = " .. tostring(G.GAME.chips))
                print("  G.GAME.blind.chips = " .. tostring(G.GAME.blind.chips))
                
                -- Only process if we haven't already this round
                if not card.ability.extra.processed_this_round then
                    local final_chips = G.GAME.chips
                    local increments = math.floor(final_chips / 666)
                    
                    print("NOOB: Processing " .. final_chips .. " chips, increments = " .. increments)
                    
                    if increments > 0 then
                        -- Add X0.01 mult for each 666 chips
                        local mult_gain = increments * 0.01
                        local old_mult = card.ability.extra.xmult
                        card.ability.extra.xmult = card.ability.extra.xmult + mult_gain
                        card.ability.extra.processed_this_round = true
                        
                        print("NOOB: GAINED MULT! " .. old_mult .. " -> " .. card.ability.extra.xmult)
                        
                        return {
                            message = "+" .. string.format("X%.2f", mult_gain) .. " Mult!",
                            colour = G.C.MULT
                        }
                    end
                end
            end
        elseif context.setting_blind and not context.blueprint then
            -- Reset for new round
            card.ability.extra.processed_this_round = false
            print("NOOB: Reset for new round")
        end
    end
}

----------------------------------------------
-- Dispenser Construction Joker
----------------------------------------------
SMODS.Joker{
    key = 'dispenser_construction',
    loc_txt = {
        name = 'Dispenser Construction',
        text = {
            "At start of round, creates",
            "{C:attention}1 Uncommon{} Joker",
            "{C:inactive}(Must have room)"
        }
    },
    config = { extra = {} },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and not context.getting_sliced then
            -- Check if there's room for another joker
            if #G.jokers.cards < G.jokers.config.card_limit then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Create an uncommon joker
                        local new_joker = create_card('Joker', G.jokers, nil, 0.9, nil, nil, nil, 'dis')
                        new_joker:add_to_deck()
                        G.jokers:emplace(new_joker)
                        new_joker:start_materialize()
                        
                        -- Show message
                        card_eval_status_text(card, 'extra', nil, nil, nil, 
                            {message = "Joker Dispensed!", colour = G.C.GREEN})
                        
                        play_sound('timpani')
                        return true
                    end
                }))
            else
                -- No room message
                card_eval_status_text(card, 'extra', nil, nil, nil, 
                    {message = "No Room!", colour = G.C.RED})
            end
        end
    end
}

----------------------------------------------
-- Fried Chicken Joker
----------------------------------------------
SMODS.Joker{
    key = 'fried_chicken',
    loc_txt = {
        name = 'Fried Chicken',
        text = {
            "{C:mult}+40{} Mult",
            "After {C:attention}2{} rounds, destroy",
            "this joker and create an",
            "{C:dark_edition}eternal{} {C:dark_edition}negative{} {C:attention}Chicken Bone{}",
            "{C:inactive}(Currently {C:attention}#1#/2{C:inactive})"
        }
    },
    config = { extra = { mult = 40, rounds_passed = 0 } },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_passed } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                card = card
            }
        elseif context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.rounds_passed = card.ability.extra.rounds_passed + 1
            
            if card.ability.extra.rounds_passed >= 2 then
                -- Transform into Chicken Bone at end of round
                if not card.ability.extra.transforming then
                    card.ability.extra.transforming = true
                    
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        func = function()
                            -- Debug: Let's find what key SMODS actually uses
                            print("DEBUG: Looking for Chicken Bone key in G.P_CENTERS")
                            for k, v in pairs(G.P_CENTERS or {}) do
                                if type(v) == "table" and v.name and (string.find(string.lower(tostring(v.name)), "chicken") or string.find(string.lower(tostring(v.name)), "bone")) then
                                    print("  Found potential match: " .. k .. " = " .. tostring(v.name))
                                end
                            end
                            
                            -- Try different possible keys
                            local possible_keys = {
                                'j_forsnakenmod_chicken_bone',
                                'j_fors_chicken_bone',
                                'j_chicken_bone',
                                'fors_chicken_bone',
                                'chicken_bone'
                            }
                            
                            local chicken_bone = nil
                            for _, key in ipairs(possible_keys) do
                                print("DEBUG: Trying key: " .. key)
                                if G.P_CENTERS[key] then
                                    print("  Key exists in G.P_CENTERS!")
                                    chicken_bone = create_card('Joker', G.jokers, nil, nil, nil, nil, key)
                                    if chicken_bone then
                                        print("  Successfully created joker with key: " .. key)
                                        break
                                    end
                                end
                            end
                            
                            -- If still no success, create a random joker and modify it
                            if not chicken_bone then
                                print("DEBUG: Failed to create Chicken Bone, using fallback")
                                chicken_bone = create_card('Joker', G.jokers, nil, 1, nil, nil, nil, 'chb')
                                
                                if chicken_bone then
                                    -- Override it to be Chicken Bone
                                    chicken_bone.ability = chicken_bone.ability or {}
                                    chicken_bone.ability.name = 'Chicken Bone'
                                    chicken_bone.ability.extra = { chips = 1 }
                                    chicken_bone.base.name = 'Chicken Bone'
                                    chicken_bone.base.nominal = 1
                                    chicken_bone.base.cost = 1
                                    chicken_bone.sell_cost = 1
                                    
                                    -- Set up the joker effect
                                    chicken_bone.calculate_joker = function(self, context)
                                        if context.joker_main then
                                            return {
                                                chips = 1,
                                                card = self,
                                                message = "+1"
                                            }
                                        end
                                    end
                                end
                            end
                            
                            if chicken_bone then
                                -- Make it eternal and negative
                                chicken_bone:set_edition({negative = true}, true)
                                chicken_bone:set_eternal(true)
                                
                                -- Add to deck
                                chicken_bone:add_to_deck()
                                G.jokers:emplace(chicken_bone)
                                chicken_bone:start_materialize()
                                
                                -- Show transformation message
                                attention_text({
                                    text = "Transformed into Chicken Bone!",
                                    scale = 1.3,
                                    hold = 2,
                                    backdrop_colour = G.C.PURPLE,
                                    align = 'cm',
                                    offset = {x = 0, y = -2},
                                    major = G.play
                                })
                                
                                play_sound('slice1')
                            end
                            
                            -- Remove the Fried Chicken card
                            card:start_dissolve()
                            return true
                        end
                    }))
                end
                
                return {
                    message = "Time to transform!",
                    colour = G.C.PURPLE
                }
            else
                return {
                    message = tostring(card.ability.extra.rounds_passed) .. "/2 Rounds",
                    colour = G.C.MULT
                }
            end
        end
    end
}

----------------------------------------------
-- Chicken Bone Joker
----------------------------------------------
SMODS.Joker{
    key = 'chicken_bone',
    loc_txt = {
        name = 'Chicken Bone',
        text = {
            "{C:chips}+1{} Chip",
            "{C:inactive}(Can only be obtained",
            "{C:inactive}through Fried Chicken)"
        }
    },
    config = { extra = { chips = 1 } },
    rarity = 1,
    cost = 1,
    unlocked = false,  -- Prevent it from appearing normally
    discovered = false,  -- Prevent it from appearing in collection
    blueprint_compat = true,
    in_pool = function(self)  -- Override pool function to prevent shop appearance
        return false
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                card = card,
                message = "+1"
            }
        end
    end
}

----------------------------------------------
-- Coin Flip Joker
----------------------------------------------
SMODS.Joker{
    key = 'coin_flip',
    loc_txt = {
        name = 'Coin Flip',
        text = {
            "{C:green}#1# in 2{} chance for",
            "{X:mult,C:white}X2{} Mult",
            "{C:red}#2# in 20{} chance to",
            "set money to {C:money}$0{}"
        }
    },
    config = { extra = { mult_chance = 1, money_chance = 1 } },
    rarity = 2,
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_chance, card.ability.extra.money_chance } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            -- Roll for x2 mult (50% chance)
            if pseudorandom('coin_flip_mult') < 0.5 then
                -- Roll for money loss (5% chance)
                if pseudorandom('coin_flip_money') < 0.05 then
                    G.GAME.dollars = 0
                    return {
                        x_mult = 2,
                        message = "Win... but at what cost?",
                        colour = G.C.RED
                    }
                else
                    return {
                        x_mult = 2,
                        message = "Heads!",
                        colour = G.C.MULT
                    }
                end
            else
                -- No mult bonus, still check for money loss
                if pseudorandom('coin_flip_money') < 0.05 then
                    G.GAME.dollars = 0
                    return {
                        message = "Bankrupt!",
                        colour = G.C.RED
                    }
                else
                    return {
                        message = "Tails...",
                        colour = G.C.INACTIVE
                    }
                end
            end
        end
    end
}

----------------------------------------------
-- Generator Joker
----------------------------------------------
SMODS.Joker{
    key = 'generator',
    loc_txt = {
        name = 'Generator',
        text = {
            "Gains {X:mult,C:white}X0.5{} Mult if played hand",
            "is a straight containing {C:attention}#1#{}",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
            "{C:inactive}(Rank changes each round)"
        }
    },
    config = { extra = { xmult = 1 } },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        -- Use the same method as Mail-In Rebate
        local rank_name = "Ace"
        if G.GAME and G.GAME.current_round and G.GAME.current_round.generator_card then
            rank_name = localize(G.GAME.current_round.generator_card.rank, 'ranks')
        end
        return { vars = { rank_name, card.ability.extra.xmult } }
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Initialize generator card like Mail-In Rebate
        if not G.GAME.current_round.generator_card then
            G.GAME.current_round.generator_card = {rank = 'Ace', id = 14}
        end
        -- Pick initial rank from deck
        local valid_cards = {}
        if G.playing_cards then
            for k, v in ipairs(G.playing_cards) do
                if v.ability.effect ~= 'Stone Card' then
                    valid_cards[#valid_cards+1] = v
                end
            end
        end
        if valid_cards[1] then 
            local generator_card = pseudorandom_element(valid_cards, pseudoseed('generator'..G.GAME.round_resets.ante))
            G.GAME.current_round.generator_card.rank = generator_card.base.value
            G.GAME.current_round.generator_card.id = generator_card.base.id
        end
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            -- Initialize if needed
            if not G.GAME.current_round.generator_card then
                G.GAME.current_round.generator_card = {rank = 'Ace', id = 14}
            end
            
            -- Pick a new random rank from deck (exactly like Mail-In Rebate)
            local valid_cards = {}
            for k, v in ipairs(G.playing_cards) do
                if v.ability.effect ~= 'Stone Card' then
                    valid_cards[#valid_cards+1] = v
                end
            end
            if valid_cards[1] then 
                local generator_card = pseudorandom_element(valid_cards, pseudoseed('generator'..G.GAME.round_resets.ante))
                G.GAME.current_round.generator_card.rank = generator_card.base.value
                G.GAME.current_round.generator_card.id = generator_card.base.id
                
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    {message = "Target: " .. localize(generator_card.base.value, 'ranks'), colour = G.C.PURPLE})
            end
        elseif context.joker_main then
            local upgraded = false
            
            -- Check if it's a straight
            if context.scoring_name == "Straight" or context.scoring_name == "Straight Flush" then
                -- Check if the straight contains the target rank (exactly like Mail-In Rebate checks)
                local contains_rank = false
                if G.GAME.current_round.generator_card and context.full_hand then
                    for _, played_card in ipairs(context.full_hand) do
                        if played_card.base and played_card:get_id() == G.GAME.current_round.generator_card.id then
                            contains_rank = true
                            break
                        end
                    end
                end
                
                if contains_rank then
                    -- Increase the multiplier permanently
                    card.ability.extra.xmult = card.ability.extra.xmult + 0.5
                    upgraded = true
                    
                    card_eval_status_text(card, 'extra', nil, nil, nil,
                        {message = "Upgraded!", colour = G.C.MULT})
                end
            end
            
            -- Always apply the current multiplier (whether we just upgraded or not)
            if card.ability.extra.xmult > 1 then
                -- If we upgraded this hand, show both the upgrade and the mult application
                if upgraded then
                    return {
                        x_mult = card.ability.extra.xmult,
                        card = card,
                        message = "X" .. string.format("%.1f", card.ability.extra.xmult),
                        colour = G.C.MULT
                    }
                else
                    -- Just apply the mult normally
                    return {
                        x_mult = card.ability.extra.xmult,
                        card = card
                    }
                end
            end
        end
    end
}

----------------------------------------------
-- Ghostburger Joker
----------------------------------------------
SMODS.Joker{
    key = 'ghostburger',
    loc_txt = {
        name = 'Ghostburger',
        text = {
            "After {C:attention}2{} rounds, sell this",
            "card to create an invisible joker",
            "{C:inactive}(Currently {C:attention}#1#/2{C:inactive})"
        }
    },
    config = { extra = { rounds_passed = 0 } },
    rarity = 2,
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_passed } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.rounds_passed = card.ability.extra.rounds_passed + 1
            
            if card.ability.extra.rounds_passed >= 2 then
                return {
                    message = "Ready to transform!",
                    colour = G.C.PURPLE
                }
            end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff and card.ability.extra.rounds_passed >= 2 then
            -- Create an actual Invisible Joker using Balatro's system
            if #G.jokers.cards < G.jokers.config.card_limit then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Specifically create an Invisible Joker by key
                        local invisible_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_invisible')
                        if invisible_joker then
                            invisible_joker:add_to_deck()
                            G.jokers:emplace(invisible_joker)
                            invisible_joker:start_materialize()
                            
                            -- Show message
                            attention_text({
                                text = "Invisible Joker created!",
                                scale = 1.3,
                                hold = 2,
                                backdrop_colour = G.C.PURPLE,
                                align = 'cm',
                                offset = {x = 0, y = -2},
                                major = G.play
                            })
                            
                            play_sound('timpani')
                        end
                        return true
                    end
                }))
            end
        end
    end
}

----------------------------------------------
-- Bloxy Cola Joker
----------------------------------------------
SMODS.Joker{
    key = 'bloxy_cola',
    loc_txt = {
        name = 'Bloxy Cola',
        text = {
            "Creates {C:attention}3 random tags{}",
            "when sold"
        }
    },
    config = { extra = {} },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.selling_self then
            -- Create 3 random tags
            local available_tags = {
                'tag_boss', 'tag_buffoon', 'tag_charm', 'tag_coupon', 'tag_d_six',
                'tag_double', 'tag_economy', 'tag_ethereal', 'tag_foil', 'tag_garbage',
                'tag_handy', 'tag_holo', 'tag_investment', 'tag_juggle', 'tag_meteor',
                'tag_negative', 'tag_orbital', 'tag_polychrome', 'tag_rare', 'tag_skip',
                'tag_standard', 'tag_top_up', 'tag_uncommon', 'tag_voucher'
            }
            
            -- Create 3 random tags
            for i = 1, 3 do
                local random_tag_key = pseudorandom_element(available_tags, pseudoseed('bloxy_cola_' .. i))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        add_tag(Tag(random_tag_key))
                        play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                        return true
                    end
                }))
            end
        end
    end
}

----------------------------------------------
-- Slash Joker
----------------------------------------------
SMODS.Joker{
    key = 'slash',
    loc_txt = {
        name = 'Slash',
        text = {
            "Every time you add a playing",
            "card to your deck, {C:attention}2{}",
            "random playing cards are",
            "{C:red}destroyed{}"
        }
    },
    config = { extra = {} },
    rarity = 3,
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.playing_card_added and not context.blueprint then
            -- Get all playing cards in the deck
            local playing_cards = {}
            for _, deck_card in ipairs(G.deck.cards) do
                if deck_card.playing_card then
                    table.insert(playing_cards, deck_card)
                end
            end
            
            -- Destroy 2 random playing cards if there are enough
            if #playing_cards >= 2 then
                local destroyed_cards = {}
                for i = 1, 2 do
                    local random_card = pseudorandom_element(playing_cards, pseudoseed('slash_destroy_' .. i))
                    table.insert(destroyed_cards, random_card)
                    -- Remove from playing_cards to avoid duplicates
                    for j = #playing_cards, 1, -1 do
                        if playing_cards[j] == random_card then
                            table.remove(playing_cards, j)
                            break
                        end
                    end
                end
                
                -- Destroy the cards with proper effects
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function() 
                        for i = #destroyed_cards, 1, -1 do
                            local card_to_destroy = destroyed_cards[i]
                            if card_to_destroy.ability.name == 'Glass Card' then 
                                card_to_destroy:shatter()
                            else
                                card_to_destroy:start_dissolve(nil, i == #destroyed_cards)
                            end
                        end
                        return true 
                    end
                }))
                
                -- Show message
                card_eval_status_text(card, 'extra', nil, nil, nil, 
                    {message = "2 Cards Destroyed!", colour = G.C.RED})
            end
        end
    end
}

----------------------------------------------
-- Dispenser Construction Joker
----------------------------------------------
SMODS.Joker{
    key = 'dispenser_construction',
    loc_txt = {
        name = 'Dispenser Construction',
        text = {
            "At start of round, creates",
            "{C:attention}1 Uncommon{} Joker",
            "{C:inactive}(Must have room)"
        }
    },
    config = { extra = {} },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and not context.getting_sliced then
            -- Check if there's room for another joker
            if #G.jokers.cards < G.jokers.config.card_limit then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Create an uncommon joker
                        local new_joker = create_card('Joker', G.jokers, nil, 0.9, nil, nil, nil, 'dis')
                        new_joker:add_to_deck()
                        G.jokers:emplace(new_joker)
                        new_joker:start_materialize()
                        
                        -- Show message
                        card_eval_status_text(card, 'extra', nil, nil, nil, 
                            {message = "Joker Dispensed!", colour = G.C.GREEN})
                        
                        play_sound('timpani')
                        return true
                    end
                }))
            else
                -- No room message
                card_eval_status_text(card, 'extra', nil, nil, nil, 
                    {message = "No Room!", colour = G.C.RED})
            end
        end
    end
}


----------------------------------------------
-- Tripwire Joker
----------------------------------------------
SMODS.Joker{
    key = 'tripwire',
    loc_txt = {
        name = 'Tripwire',
        text = {
            "Played cards with {V:1}#1#{} suit give {X:mult,C:white}X2{} Mult",
            "Played cards with {V:2}#2#{} suit give {X:mult,C:white}X0.5{} Mult",
            "the two suits cannot be the same"
        }
    },
    config = { extra = {} },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        -- Initialize if needed
        if not G.GAME or not G.GAME.current_round then
            return { vars = { "Spades", "Hearts" } }
        end
        
        if not G.GAME.current_round.tripwire_good_suit then
            reset_tripwire_suits()
        end
        
        local good_suit = G.GAME.current_round.tripwire_good_suit or 'Spades'
        local bad_suit = G.GAME.current_round.tripwire_bad_suit or 'Hearts'
        
        -- Format exactly like Ancient Joker does it
        return { 
            vars = { 
                localize(good_suit, 'suits_singular'),
                localize(bad_suit, 'suits_singular'),
                colours = {
                    G.C.SUITS[good_suit],
                    G.C.SUITS[bad_suit]
                }
            }
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            reset_tripwire_suits()
        end
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit(G.GAME.current_round.tripwire_good_suit) then
                return {
                    x_mult = 2,
                    card = card,
                    message = "X2!",
                    colour = G.C.MULT
                }
            elseif context.other_card:is_suit(G.GAME.current_round.tripwire_bad_suit) then
                return {
                    x_mult = 0.5,
                    card = card,
                    message = "X0.5!",
                    colour = G.C.RED
                }
            end
        elseif context.end_of_round and not context.blueprint then
            -- Reset suits for next round
            reset_tripwire_suits()
        end
    end
}

-- Helper function to reset Tripwire suits (like Ancient Joker)
function reset_tripwire_suits()
    -- Initialize round data if needed
    if not G or not G.GAME or not G.GAME.current_round then return end
    
    -- Get all suits
    local all_suits = {'Spades', 'Hearts', 'Clubs', 'Diamonds'}
    
    -- Get ante for seed (default to 1 if not available)
    local ante = (G.GAME.round_resets and G.GAME.round_resets.ante) or 1
    
    -- Pick good suit
    local good_suit = pseudorandom_element(all_suits, pseudoseed('tripwire_good'..ante))
    
    -- Pick bad suit (different from good suit)
    local remaining_suits = {}
    for _, suit in ipairs(all_suits) do
        if suit ~= good_suit then
            table.insert(remaining_suits, suit)
        end
    end
    local bad_suit = pseudorandom_element(remaining_suits, pseudoseed('tripwire_bad'..ante))
    
    -- Store in game state like Ancient Joker does
    G.GAME.current_round.tripwire_good_suit = good_suit
    G.GAME.current_round.tripwire_bad_suit = bad_suit
end