-- ~/.config/nvim/init.lua
-- AI-Enabled VI Editor (local Ollama + natural language → Vim commands developed by Peyton Lassiter Sr. :)

local function ai_command(prompt)
  if prompt == "" then
    vim.ui.input({ prompt = "AI Command (natural language): " }, function(input)
      if not input or input == "" then return end
      ai_command(input)
    end)
    return
  end

  vim.notify("🤖 Thinking...", vim.log.levels.INFO)

  -- Strong system prompt so the model ONLY outputs clean JSON with a valid command
  local system_prompt = [[You are an expert Vim/Neovim command generator.
You will be given a natural language request.
Respond with ONLY valid JSON in this exact format:
{"command": "the exact :ex-command or normal-mode keys to run"}
Examples:
User: delete all lines containing error
{"command": ":%g/error/d"}
User: center this paragraph
{"command": "vip: center"}
User: add a comment above this function
{"command": "O// TODO: "}

Never explain, never add extra text. Only the JSON.]]

  local body = vim.json.encode({
    model = "llama3.2:3b",
    prompt = system_prompt .. "\n\nUser request: " .. prompt,
    stream = false,
    temperature = 0.2,
    num_predict = 200,
  })

  local cmd = string.format(
    'curl -s http://localhost:11434/api/generate -d %s',
    vim.fn.shellescape(body)
  )

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data or #data == 0 then return end
      local output = table.concat(data)
      local ok, json = pcall(vim.json.decode, output)
      if not ok or not json.response then
        vim.notify("❌ Failed to parse AI response", vim.log.levels.ERROR)
        return
      end

      -- Extract the command from the JSON the model returned
      local cmd_ok, result = pcall(vim.json.decode, json.response)
      if not cmd_ok or not result.command then
        vim.notify("❌ AI did not return valid JSON", vim.log.levels.ERROR)
        return
      end

      local vim_command = result.command

      -- Confirmation dialog (feels like the classic : prompt)
      vim.ui.input({
        prompt = "🤖 Run this command?  " .. vim_command .. "   (y = yes, e = edit, n = no) ",
      }, function(choice)
        if choice == "y" or choice == "Y" then
          vim.cmd(vim_command)
          vim.notify("✅ Executed: " .. vim_command, vim.log.levels.INFO)
        elseif choice == "e" or choice == "E" then
          -- Prefill the command line so user can edit
          vim.schedule(function()
            vim.api.nvim_feedkeys(":" .. vim_command, "n", false)
          end)
        else
          vim.notify("🚫 Cancelled", vim.log.levels.WARN)
        end
      end)
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        vim.notify("Ollama error: " .. table.concat(data), vim.log.levels.ERROR)
      end
    end,
  })
end

-- Create the :AI command (works exactly like you wanted)
vim.api.nvim_create_user_command("AI", function(opts)
  ai_command(opts.args)
end, { nargs = "*", complete = "file" })

-- Optional: <leader>ai also opens the prompt (very convenient)
vim.keymap.set("n", "<leader>ai", function()
  ai_command("")
end, { desc = "AI Natural Language Command" })

-- Bonus: Visual mode support (select text first, then :AI)
vim.api.nvim_create_user_command("AIV", function(opts)
  local lines = vim.api.nvim_buf_get_lines(0, vim.fn.line("'<") - 1, vim.fn.line("'>"), false)
  local selected = table.concat(lines, "\n")
  local full_prompt = opts.args .. "\n\nSelected text:\n" .. selected
  ai_command(full_prompt)
end, { nargs = "*", range = true })

vim.notify("🚀 AI-Enabled VI is ready! Type :AI or <leader>ai", vim.log.levels.INFO)
