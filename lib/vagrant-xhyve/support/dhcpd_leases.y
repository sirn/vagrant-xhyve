class VagrantPlugins::Xhyve::Support::DhcpdLeases
rule

blocks:
  '{' body '}' { result = [val[1]] }
  | blocks '{' body '}' { result = result.push(val[2]) }
body:
  IDENT '=' IDENT { result = {val[0] => val[2]} }
  | body IDENT '=' IDENT { result[val[1]] = val[3] }

---- inner

def parse(str)
  @str = str
  yyparse self, :scan
end

private

def scan
  str = @str

  until str.empty?
    case str
    when /\A\s+/
      str = $'
    when /\A[\w\.\,\:]+/
      yield([:IDENT, $&])
      str = $'
    else
      c = str[0, 1]
      yield([c, c])
      str = str[1..-1]
    end
  end

  yield([false, '$'])
end
