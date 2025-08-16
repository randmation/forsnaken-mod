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
                -- Transform into Chicken Bone
                G.E_MANAGER:add_event(Event({
                    func = function()
                        -- Create Chicken Bone joker
                        local chicken_bone = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_forsnakenmod_chicken_bone')
                        
                        -- Make it eternal and negative
                        chicken_bone:set_edition({negative = true}, true)
                        chicken_bone:set_eternal(true)
                        
                        -- Add to deck at the same position
                        chicken_bone:add_to_deck()
                        G.jokers:emplace(chicken_bone)
                        
                        -- Remove this card
                        card:start_dissolve()
                        
                        -- Show message
                        card_eval_status_text(chicken_bone, 'extra', nil, nil, nil, 
                            {message = "Transformed!", colour = G.C.PURPLE})
                        
                        play_sound('slice1')
                        return true
                    end
                }))
                
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
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    in_pool = function(self)
        -- Cannot appear in normal pools, only from Fried Chicken
        return false
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                card = card
            }
        end
    end
}