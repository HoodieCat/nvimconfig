return {
  --dap fram put first
  'mfussenegger/nvim-dap',
  dependencies = {
    --dap ui frame
    'rcarriga/nvim-dap-ui',
    -- ui depency
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
  },
  config = function()
    local dap = require 'dap'
    local ui = require 'dapui'

    require('dapui').setup()
    require('nvim-dap-virtual-text').setup {}
    --use mason-nvim-dap to install dap adapters and configurations
    require('mason-nvim-dap').setup {
      ensure_installed = {
        'cppdbg',
        'delve',
      },
      automatic_installation = true,
      handlers = {
        --default dap handler
        function(config)
          require('mason-nvim-dap').default_setup(config)
        end,
        --cpp/c/rust dap config by handler
        cppdbg = function(config)
          config.adapters = {
            id = 'cppdbg',
            type = 'executable',
            command = vim.fn.exepath 'OpenDebugAD7',
          }
          config.configurations = {
            --launch configuration
            {
              name = 'Launch file',
              type = 'cppdbg',
              request = 'launch',
              program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
              end,
              cwd = '${workspaceFolder}',
              stopAtEntry = true,
              setupCommands = {
                {
                  text = '-enable-pretty-printing',
                  description = 'enable pretty printing',
                  ignoreFailures = false,
                },
              },
            },
            {
              --attach configuration
              name = 'Attach to gdbserver :1234',
              type = 'cppdbg',
              request = 'launch',
              MIMode = 'gdb',
              miDebuggerServerAddress = 'localhost:1234',
              miDebuggerPath = '/usr/bin/gdb',
              cwd = '${workspaceFolder}',
              program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
              end,
              setupCommands = {
                {
                  text = '-enable-pretty-printing',
                  description = 'enable pretty printing',
                  ignoreFailures = false,
                },
              },
            },
          }
          config.filetypes = { 'c', 'cpp', 'rust', 'zig' }
          require('mason-nvim-dap').default_setup(config)
        end,
      },
    }
    --keymap for DAP
    vim.keymap.set('n', '<F1>', dap.continue, { desc = 'Debug: start/continue' })
    vim.keymap.set('n', '<F2>', dap.step_into, { desc = 'Debug: step_into' })
    vim.keymap.set('n', '<F3>', dap.step_over, { desc = 'Debug: step_over' })
    vim.keymap.set('n', '<F4>', dap.step_out, { desc = 'Debug: step_out' })
    vim.keymap.set('n', '<F5>', dap.step_back, { desc = 'Debug: step_back' })
    vim.keymap.set('n', '<F8>', dap.restart, { desc = 'Debug: restart' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = '[T]oggle breankpoint' })
    vim.keymap.set('n', '<leader>db', dap.clear_breakpoints, { desc = '[D]elete [B]reakpoints' })
    vim.keymap.set('n', '<leader>gc', dap.run_to_cursor, { desc = '[G]o to [C]ursor' })
    vim.keymap.set('n', 'K', function()
      require('dapui').eval(nil, { enter = true })
    end)
    --breakpoint icon
    ui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    --dap ui listeners set
    dap.listeners.before.attach.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      ui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      ui.close()
    end
  end,
}
