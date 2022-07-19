require "ripper"
require 'github/markup'

module Textbringer

  class MarkdownMode < ProgrammingMode
    self.file_name_pattern =
      /\A(?:.*\.(?:md|markdown))\z/ix
  end

  module Commands
    define_command(:markdown_to_html, doc: "markdown to html.") do
      html="#{Buffer.current.name.to_s}.html"
      File.open(html,"w"){|file|
        file.puts('
<head>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.1.0/github-markdown.min.css" integrity="sha512-KUoB3bZ1XRBYj1QcH4BHCQjurAZnCO3WdrswyLDtp7BMwCw7dPZngSLqILf68SGgvnWHTD5pPaYrXi6wiRJ65g==" crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<article class="markdown-body">
    ')
        file.puts(GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, Buffer.current.to_s))
        file.puts('</article>')
      }
    end
  end

  GLOBAL_MAP.define_key("\C-xd", :markdown_to_html)

end

