-- CUSTOM COMMANDS
vim.api.nvim_create_user_command('HexEditor', '%!xxd', {})
vim.api.nvim_create_user_command('Cmus', 'silent !cmus-remote <args>', {
	nargs = '+',
	complete = function(ArgLead, CmdLine, CursorPos)
		return {
			'--play',
			'-p',
			'--pause',
			'-u',
			'--stop',
			'-s',
			'--next',
			'-n',
			'--prev',
			'-r',
			'--repeat',
			'-R',
			'--clear',
			'-c',
			'--shuffle',
			'-S',
			'--file',
			'-f',
			'-Q', -- player status information
			'--queue',
			'-q',
			'--raw', -- insert command
			'-C', -- insert command
		}
	end
})
