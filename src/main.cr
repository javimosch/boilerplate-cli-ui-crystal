require "http/server"
require "json"

class AppHandler
  include HTTP::Handler

  def initialize(@port : Int32)
  end

  def call(context)
    path = context.request.path

    # Handle API endpoints
    if path == "/api/status"
      data = {
        "status"  => "running",
        "port"    => @port.to_s,
        "uptime"  => "0s",
        "version" => "1.0.0"
      }.to_json
      context.response.content_type = "application/json"
      context.response.print(data)
      return
    end

    if path == "/api/health"
      data = {
        "status"  => "healthy",
        "version" => "1.0.0"
      }.to_json
      context.response.content_type = "application/json"
      context.response.print(data)
      return
    end

    # Serve static files
    file_path = path == "/" ? "/index.html" : path

    # Remove query string
    file_path = file_path.split("?")[0]

    # Get the current executable directory
    exe_path = Process.executable_path || "."
    exe_dir = File.dirname(exe_path)
    web_dir = File.join(exe_dir, "web")
    full_path = File.join(web_dir, file_path.lstrip('/'))

    if File.exists?(full_path)
      content = File.read(full_path)
      content_type = get_content_type(full_path)
      context.response.content_type = content_type
      context.response.print(content)
    else
      # Try index.html for directory requests
      if !path.ends_with?('/')
        index_path = File.join(web_dir, "#{path.lstrip('/')}/index.html")
        if File.exists?(index_path)
          content = File.read(index_path)
          context.response.content_type = "text/html"
          context.response.print(content)
          return
        end
      end
      context.response.status_code = 404
      context.response.print("Not found")
    end
  end

  private def get_content_type(file_path : String) : String
    case file_path
    when .ends_with?(".html") then "text/html"
    when .ends_with?(".css")  then "text/css"
    when .ends_with?(".js")   then "application/javascript"
    when .ends_with?(".json") then "application/json"
    when .ends_with?(".svg")  then "image/svg+xml"
    when .ends_with?(".png")  then "image/png"
    when .ends_with?(".jpg")  then "image/jpeg"
    else                          "text/plain"
    end
  end
end

def print_help
  puts "boilerplate-cli-ui-crystal - Crystal CLI with embedded web UI"
  puts ""
  puts "Usage:"
  puts "  boilerplate-cli-ui-crystal <command> [options]"
  puts ""
  puts "Commands:"
  puts "  start       Start HTTP server with web UI"
  puts "  version     Show version information"
  puts "  help        Show this help message"
  puts ""
  puts "Start Options:"
  puts "  -p, --port PORT  Port for HTTP server (default 8080)"
  puts ""
  puts "API Endpoints:"
  puts "  GET /            Web UI"
  puts "  GET /api/status  Server status (JSON)"
  puts "  GET /api/health  Health check (JSON)"
end

def start_server(args : Array(String))
  port = 8080

  args.each_with_index do |arg, i|
    if arg == "-p" || arg == "--port"
      if i + 1 < args.size
        port = args[i + 1].to_i
      end
    end
  end

  puts "Server starting on http://localhost:#{port}/"
  puts "UI available at http://localhost:#{port}/"
  puts "API available at http://localhost:#{port}/api/status"
  puts "Press Ctrl+C to stop"

  handler = AppHandler.new(port)
  server = HTTP::Server.new(handler)

  address = server.bind_tcp("0.0.0.0", port)
  puts "Server started successfully"
  server.listen
end

if ARGV.size < 1
  puts "Usage: boilerplate-cli-ui-crystal <command> [options]"
  puts ""
  puts "Commands:"
  puts "  start       Start HTTP server with web UI"
  puts "  version     Show version information"
  puts "  help        Show this help message"
  puts ""
  puts "Start Options:"
  puts "  -p, --port PORT  Port for HTTP server (default 8080)"
  exit(0)
end

# Handle Crystal run command which passes the script path as first arg
if ARGV[0].ends_with?(".cr") || ARGV[0] == "run"
  args = ARGV[1..]
  if args.size < 1
    puts "Usage: boilerplate-cli-ui-crystal <command> [options]"
    puts ""
    puts "Commands:"
    puts "  start       Start HTTP server with web UI"
    puts "  version     Show version information"
    puts "  help        Show this help message"
    puts ""
    puts "Start Options:"
    puts "  -p, --port PORT  Port for HTTP server (default 8080)"
    exit(0)
  end
  command = args[0]
  remaining_args = args[1..]
else
  command = ARGV[0]
  remaining_args = ARGV[1..]
end

case command
when "start"
  start_server(remaining_args)
when "version"
  puts "boilerplate-cli-ui-crystal v1.0.0"
when "help"
  print_help
else
  puts "Unknown command: #{command}"
end