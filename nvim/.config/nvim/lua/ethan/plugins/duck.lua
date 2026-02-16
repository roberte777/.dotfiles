return {
	{
		"tamton-aquib/duck.nvim",
		config = function()
			local duck = require("duck")

			vim.keymap.set("n", "<leader>udd", function()
				duck.hatch("🦀")
			end, { desc = "Hatch duck" })
			vim.keymap.set("n", "<leader>udk", function()
				require("duck").cook()
			end, { desc = "Cook Duck" })
			vim.keymap.set("n", "<leader>uda", function()
				require("duck").cook_all()
			end, { desc = "Cook all ducks" })

			local state = {
				alive = 0,
				max = 2,
			}

			local function hatch()
				if state.alive >= state.max then
					return
				end
				duck.hatch("🦀")
				state.alive = state.alive + 1
			end

			local function cook_one()
				-- duck.cook() typically cooks one duck
				duck.cook()
				state.alive = math.max(0, state.alive - 1)
			end

			local function maybe_change_ducks()
				-- Nothing to do
				if state.alive == 0 then
					-- Higher chance to spawn when empty
					if math.random() < 0.05 then
						hatch()
					end
					return
				end

				if state.alive >= state.max then
					-- Higher chance to cook when at cap
					if math.random() < 0.15 then
						cook_one()
					end
					return
				end

				-- Exactly 1 duck: spawn or cook, both are possible
				local roll = math.random()
				if roll < 0.05 then
					hatch()
				elseif roll < 0.05 then
					cook_one()
				end
			end
			local aug = vim.api.nvim_create_augroup("DuckRandom", { clear = true })

			vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "CursorHold" }, {
				group = aug,
				callback = maybe_change_ducks,
			})
		end,
	},
}
