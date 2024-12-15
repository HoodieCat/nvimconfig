return {
  'imacco/markdown-preview',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  build = 'cd app && yarn install',
  ft = { 'markdown' },
  config = function()
    vim.keymap.set('n', '<leader>mp', '<Plug>MarkdownPreviewToggle', { desc = '[m]arkdown [p]preview' })
  end,
}
