import cli
import os
import regex

// Remove redundant readme section from module page.
fn rm_readme_section(html string) string {
	mut r := regex.regex_opt(r'<section id="readme_vtray".*</section>') or { panic(err) }
	sec_start, sec_end := r.find(html)
	return '${html[..sec_start]}</section>${html[sec_end..]}'
		.replace('<li class="open"><a href="#readme_vtray">README</a></li>', '')
}

fn build_docs() ! {
	// Cleanup old docs.
	rmdir_all('_docs') or {}

	// Build docs.
	mut p := new_process(@VEXE)
	p.set_args(['doc', '-readme', '-m', '-f', 'html', '.'])
	p.wait()

	// Prepare html.
	mut vtray_html := read_file('_docs/vtray.html')!
	vtray_html = rm_readme_section(vtray_html)
	write_file('_docs/vtray.html', vtray_html)!
}

mut cmd := cli.Command{
	name: 'build.vsh'
	posix_mode: true
	required_args: 0
	pre_execute: fn (cmd cli.Command) ! {
		if cmd.args.len > cmd.required_args {
			eprintln('Unknown commands ${cmd.args}.\n')
			cmd.execute_help()
			exit(0)
		}
	}
	execute: fn (_cmd cli.Command) ! {
		build_docs()!
	}
}
cmd.parse(os.args)
