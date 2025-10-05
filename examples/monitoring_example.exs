# examples/monitoring_example.exs
#
# This example demonstrates the monitoring and metrics capabilities in ExUtcp.
# It shows how to use telemetry events, Prometheus metrics, health checks, and performance monitoring.
#
# To run this example:
# elixir examples/monitoring_example.exs

alias ExUtcp.{Client, Providers, Monitoring}
alias ExUtcp.Monitoring.{HealthCheck, Performance, Metrics}

# Start the ExUtcp application
{:ok, _} = Application.ensure_all_started(:ex_utcp)

IO.puts "=== ExUtcp Monitoring and Metrics Example ==="

# 1. Start the monitoring system
IO.puts "\n1. Starting monitoring system..."
:ok = Monitoring.start()
IO.puts "✅ Monitoring system started"

# 2. Start health check system
IO.puts "\n2. Starting health check system..."
{:ok, health_pid} = HealthCheck.start_link(check_interval: 10_000)
IO.puts "✅ Health check system started"

# 3. Start metrics collector
IO.puts "\n3. Starting metrics collector..."
{:ok, metrics_pid} = Metrics.start_link()
IO.puts "✅ Metrics collector started"

# 4. Start the client with monitoring
IO.puts "\n4. Starting UTCP client..."
{:ok, client} = Client.start_link()
IO.puts "✅ UTCP client started"

# 5. Register some providers for monitoring
IO.puts "\n5. Registering providers..."
providers = [
  Providers.new_http_provider(
    name: "api_service",
    url: "https://api.example.com",
    http_method: "GET"
  ),
  Providers.new_websocket_provider(
    name: "realtime_service",
    url: "wss://realtime.example.com"
  )
]

Enum.each(providers, fn provider ->
  case Client.register_tool_provider(client, provider) do
    {:ok, tools} ->
      IO.puts "  ✅ Registered #{provider.name} with #{length(tools)} tools"

      # Emit provider registration event
      Monitoring.emit_provider_event(
        provider.name,
        provider.type,
        :register,
        length(tools)
      )
    {:error, reason} ->
      IO.puts "  ❌ Failed to register #{provider.name}: #{inspect(reason)}"
  end
end)

# 6. Demonstrate performance monitoring
IO.puts "\n6. Demonstrating performance monitoring..."

# Simulate some tool calls with performance measurement
tool_calls = [
  {"get_user", %{"user_id" => "123"}},
  {"create_post", %{"title" => "Test Post", "content" => "Test content"}},
  {"send_notification", %{"message" => "Hello", "user_id" => "123"}}
]

Enum.each(tool_calls, fn {tool_name, args} ->
  IO.puts "  Calling tool: #{tool_name}"

  # Measure the tool call (will fail since we don't have real providers, but shows monitoring)
  try do
    Performance.measure_tool_call(tool_name, "api_service", args, fn ->
      # Simulate some work
      Process.sleep(:rand.uniform(100))

      # Simulate success or failure
      if :rand.uniform(10) > 8 do
        raise "Simulated error"
      else
        {:ok, %{"result" => "success", "tool" => tool_name}}
      end
    end)

    IO.puts "    ✅ Tool call completed successfully"
  rescue
    error ->
      IO.puts "    ❌ Tool call failed: #{inspect(error.message)}"
  end
end)

# 7. Demonstrate search monitoring
IO.puts "\n7. Demonstrating search monitoring..."

search_queries = [
  {"user", :exact},
  {"usr", :fuzzy},
  {"user management", :semantic},
  {"api", :combined}
]

Enum.each(search_queries, fn {query, algorithm} ->
  IO.puts "  Searching: '#{query}' with #{algorithm} algorithm"

  results = Performance.measure_search(query, algorithm, %{}, fn ->
    # Simulate search operation
    Process.sleep(:rand.uniform(50))

    # Return mock results
    [
      %{tool: %{name: "mock_tool_1"}, score: 0.9, match_type: algorithm},
      %{tool: %{name: "mock_tool_2"}, score: 0.7, match_type: algorithm}
    ]
  end)

  IO.puts "    ✅ Found #{length(results)} results"
end)

# 8. Get current metrics
IO.puts "\n8. Current system metrics:"
system_metrics = Monitoring.get_metrics()

IO.puts "  Memory Usage:"
memory = system_metrics.system.memory
IO.puts "    Total: #{Float.round(memory.total / 1_000_000, 2)} MB"
IO.puts "    Processes: #{Float.round(memory.processes / 1_000_000, 2)} MB"
IO.puts "    System: #{Float.round(memory.system / 1_000_000, 2)} MB"

IO.puts "  Process Info:"
processes = system_metrics.system.processes
IO.puts "    Count: #{processes.count}"
IO.puts "    Limit: #{processes.limit}"
IO.puts "    Usage: #{Float.round(processes.count / processes.limit * 100, 1)}%"

# 9. Get health status
IO.puts "\n9. Health status:"
health_status = HealthCheck.get_health_status()

IO.puts "  Overall Status: #{health_status.status}"
IO.puts "  Component Health:"
Enum.each(health_status.checks, fn {component, check_result} ->
  status_icon = case check_result.status do
    :healthy -> "✅"
    :degraded -> "⚠️"
    :unhealthy -> "❌"
    _ -> "❓"
  end

  IO.puts "    #{status_icon} #{component}: #{check_result.message} (#{check_result.duration_ms}ms)"
end)

# 10. Get performance summary
IO.puts "\n10. Performance summary:"
perf_summary = Performance.get_performance_summary()

IO.puts "  System Performance:"
system_perf = perf_summary.system
IO.puts "    Memory: #{system_perf.memory_mb} MB"
IO.puts "    Processes: #{system_perf.process_count}"

if length(perf_summary.alerts) > 0 do
  IO.puts "  ⚠️  Performance Alerts:"
  Enum.each(perf_summary.alerts, fn alert ->
    IO.puts "    - #{alert.message}"
  end)
else
  IO.puts "  ✅ No performance alerts"
end

# 11. Custom metrics demonstration
IO.puts "\n11. Recording custom metrics..."

# Record some custom metrics
Performance.record_custom_metric("example_requests", :counter, 1, %{endpoint: "/api/users"})
Performance.record_custom_metric("response_time", :histogram, 150, %{endpoint: "/api/users"})
Performance.record_custom_metric("active_connections", :gauge, 25, %{transport: "websocket"})
Performance.record_custom_metric("throughput", :summary, 1000, %{operation: "search"})

IO.puts "  ✅ Custom metrics recorded"

# 12. Get collected metrics
IO.puts "\n12. Collected metrics summary:"
metrics_summary = Metrics.get_metrics_summary()

IO.puts "  Uptime: #{Float.round(metrics_summary.uptime_ms / 1000, 2)} seconds"
IO.puts "  Total Metrics: #{metrics_summary.total_metrics}"
IO.puts "  Memory Usage: #{Float.round(metrics_summary.memory_usage / 1_000_000, 2)} MB"
IO.puts "  Process Count: #{metrics_summary.process_count}"

# 13. Register custom health check
IO.puts "\n13. Registering custom health check..."

custom_health_check = fn ->
  # Simulate a custom health check
  if :rand.uniform(10) > 2 do
    %{
      status: :healthy,
      message: "Custom service is operational"
    }
  else
    %{
      status: :degraded,
      message: "Custom service is experiencing issues"
    }
  end
end

HealthCheck.register_check("custom_service", custom_health_check)
IO.puts "  ✅ Custom health check registered"

# Run health checks to see the custom check
updated_health = HealthCheck.run_health_checks()
custom_check = updated_health.checks["custom_service"]
IO.puts "  Custom Service Health: #{custom_check.status} - #{custom_check.message}"

# 14. Cleanup
IO.puts "\n14. Cleaning up..."

# Stop monitoring components
GenServer.stop(metrics_pid)
GenServer.stop(health_pid)
GenServer.stop(client)
Monitoring.stop()

IO.puts "✅ Monitoring example completed!"

IO.puts """

=== Summary ===
This example demonstrated:
- Telemetry event emission for operations
- Performance measurement with automatic metrics collection
- Health check system with custom checks
- Prometheus metrics integration (PromEx)
- Custom metrics recording and collection
- System monitoring and alerting
- Performance analysis and reporting

In a production environment, you would:
- Configure PromEx to expose metrics on an HTTP endpoint
- Set up Grafana dashboards for visualization
- Configure alerting rules for performance thresholds
- Integrate with external monitoring systems
- Set up log aggregation and analysis
"""

