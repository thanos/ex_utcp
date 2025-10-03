#!/usr/bin/env elixir

# OpenAPI Converter Example
# Demonstrates how to convert OpenAPI specifications to UTCP tools

defmodule OpenApiConverterExample do
  @moduledoc """
  Example demonstrating OpenAPI Converter usage.
  """

  alias ExUtcp.OpenApiConverter

  def run do
    IO.puts("=== OpenAPI Converter Example ===\n")

    # Example 1: Convert from a simple OpenAPI 2.0 spec
    example_1()

    # Example 2: Convert from OpenAPI 3.0 spec with authentication
    example_2()

    # Example 3: Convert from URL (GitHub API)
    example_3()

    # Example 4: Convert multiple specs
    example_4()

    # Example 5: Validate OpenAPI spec
    example_5()
  end

  defp example_1 do
    IO.puts("1. Converting OpenAPI 2.0 spec to UTCP tools...")

    spec = %{
      "swagger" => "2.0",
      "info" => %{
        "title" => "User Management API",
        "version" => "1.0.0",
        "description" => "A simple API for managing users"
      },
      "host" => "api.example.com",
      "basePath" => "/v1",
      "schemes" => ["https"],
      "paths" => %{
        "/users" => %{
          "get" => %{
            "operationId" => "getUsers",
            "summary" => "Get all users",
            "description" => "Retrieve a list of all users",
            "parameters" => [
              %{
                "name" => "limit",
                "in" => "query",
                "type" => "integer",
                "required" => false,
                "description" => "Number of users to return",
                "default" => 10
              },
              %{
                "name" => "offset",
                "in" => "query",
                "type" => "integer",
                "required" => false,
                "description" => "Number of users to skip",
                "default" => 0
              }
            ],
            "responses" => %{
              "200" => %{
                "description" => "Successful response",
                "schema" => %{
                  "type" => "array",
                  "items" => %{
                    "type" => "object",
                    "properties" => %{
                      "id" => %{"type" => "integer", "description" => "User ID"},
                      "name" => %{"type" => "string", "description" => "User name"},
                      "email" => %{"type" => "string", "description" => "User email"}
                    },
                    "required" => ["id", "name", "email"]
                  }
                }
              }
            }
          },
          "post" => %{
            "operationId" => "createUser",
            "summary" => "Create a new user",
            "description" => "Create a new user in the system",
            "parameters" => [
              %{
                "name" => "user",
                "in" => "body",
                "required" => true,
                "schema" => %{
                  "type" => "object",
                  "properties" => %{
                    "name" => %{"type" => "string", "description" => "User name"},
                    "email" => %{"type" => "string", "description" => "User email"}
                  },
                  "required" => ["name", "email"]
                }
              }
            ],
            "responses" => %{
              "201" => %{
                "description" => "User created successfully",
                "schema" => %{
                  "type" => "object",
                  "properties" => %{
                    "id" => %{"type" => "integer"},
                    "name" => %{"type" => "string"},
                    "email" => %{"type" => "string"}
                  }
                }
              }
            }
          }
        },
        "/users/{id}" => %{
          "get" => %{
            "operationId" => "getUser",
            "summary" => "Get user by ID",
            "description" => "Retrieve a specific user by their ID",
            "parameters" => [
              %{
                "name" => "id",
                "in" => "path",
                "type" => "integer",
                "required" => true,
                "description" => "User ID"
              }
            ],
            "responses" => %{
              "200" => %{
                "description" => "User found",
                "schema" => %{
                  "type" => "object",
                  "properties" => %{
                    "id" => %{"type" => "integer"},
                    "name" => %{"type" => "string"},
                    "email" => %{"type" => "string"}
                  }
                }
              },
              "404" => %{
                "description" => "User not found"
              }
            }
          }
        }
      }
    }

    case OpenApiConverter.convert(spec) do
      {:ok, manual} ->
        IO.puts("✓ Successfully converted OpenAPI 2.0 spec")
        IO.puts("  Manual: #{manual.name}")
        IO.puts("  Description: #{manual.description}")
        IO.puts("  Tools generated: #{length(manual.tools)}")

        Enum.each(manual.tools, fn tool ->
          IO.puts("    - #{tool.name}: #{tool.description}")
          IO.puts("      Provider: #{tool.provider.http_method} #{tool.provider.url}")
        end)
      {:error, reason} ->
        IO.puts("✗ Failed to convert spec: #{reason}")
    end

    IO.puts("")
  end

  defp example_2 do
    IO.puts("2. Converting OpenAPI 3.0 spec with authentication...")

    spec = %{
      "openapi" => "3.0.0",
      "info" => %{
        "title" => "Secure API",
        "version" => "1.0.0",
        "description" => "A secure API with authentication"
      },
      "servers" => [
        %{"url" => "https://secure-api.example.com/v1"}
      ],
      "components" => %{
        "securitySchemes" => %{
          "apiKey" => %{
            "type" => "apiKey",
            "name" => "X-API-Key",
            "in" => "header",
            "description" => "API key for authentication"
          },
          "bearerAuth" => %{
            "type" => "http",
            "scheme" => "bearer",
            "bearerFormat" => "JWT",
            "description" => "JWT token authentication"
          }
        }
      },
      "paths" => %{
        "/protected" => %{
          "get" => %{
            "operationId" => "getProtectedData",
            "summary" => "Get protected data",
            "description" => "Retrieve protected data that requires authentication",
            "security" => [%{"apiKey" => []}],
            "responses" => %{
              "200" => %{
                "description" => "Protected data retrieved successfully",
                "content" => %{
                  "application/json" => %{
                    "schema" => %{
                      "type" => "object",
                      "properties" => %{
                        "data" => %{"type" => "string"},
                        "timestamp" => %{"type" => "string", "format" => "date-time"}
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    case OpenApiConverter.convert(spec) do
      {:ok, manual} ->
        IO.puts("✓ Successfully converted OpenAPI 3.0 spec with auth")
        IO.puts("  Manual: #{manual.name}")
        IO.puts("  Tools generated: #{length(manual.tools)}")

        Enum.each(manual.tools, fn tool ->
          IO.puts("    - #{tool.name}: #{tool.description}")
          IO.puts("      Provider: #{tool.provider.http_method} #{tool.provider.url}")
          if tool.provider.auth do
            IO.puts("      Auth: #{tool.provider.auth.type} (#{tool.provider.auth.var_name})")
          end
        end)
      {:error, reason} ->
        IO.puts("✗ Failed to convert spec: #{reason}")
    end

    IO.puts("")
  end

  defp example_3 do
    IO.puts("3. Converting from URL (GitHub API)...")

    # Note: This would require a real URL, so we'll show the pattern
    IO.puts("  (This example would convert from a real URL like https://api.github.com/openapi.json)")
    IO.puts("  Code example:")
    IO.puts("    {:ok, manual} = OpenApiConverter.convert_from_url(\"https://api.github.com/openapi.json\")")
    IO.puts("")

    # For demonstration, we'll create a mock GitHub-like spec
    github_spec = %{
      "openapi" => "3.0.0",
      "info" => %{
        "title" => "GitHub API",
        "version" => "1.0.0",
        "description" => "GitHub API for repository management"
      },
      "servers" => [
        %{"url" => "https://api.github.com"}
      ],
      "paths" => %{
        "/repos/{owner}/{repo}" => %{
          "get" => %{
            "operationId" => "getRepository",
            "summary" => "Get repository",
            "description" => "Get repository information",
            "parameters" => [
              %{
                "name" => "owner",
                "in" => "path",
                "required" => true,
                "schema" => %{"type" => "string"}
              },
              %{
                "name" => "repo",
                "in" => "path",
                "required" => true,
                "schema" => %{"type" => "string"}
              }
            ],
            "responses" => %{
              "200" => %{
                "description" => "Repository information",
                "content" => %{
                  "application/json" => %{
                    "schema" => %{
                      "type" => "object",
                      "properties" => %{
                        "name" => %{"type" => "string"},
                        "full_name" => %{"type" => "string"},
                        "description" => %{"type" => "string"}
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    case OpenApiConverter.convert(github_spec, prefix: "github") do
      {:ok, manual} ->
        IO.puts("✓ Successfully converted GitHub-like spec")
        IO.puts("  Manual: #{manual.name}")
        IO.puts("  Tools generated: #{length(manual.tools)}")

        Enum.each(manual.tools, fn tool ->
          IO.puts("    - #{tool.name}: #{tool.description}")
        end)
      {:error, reason} ->
        IO.puts("✗ Failed to convert spec: #{reason}")
    end

    IO.puts("")
  end

  defp example_4 do
    IO.puts("4. Converting multiple specs...")

    spec1 = %{
      "swagger" => "2.0",
      "info" => %{"title" => "User API", "version" => "1.0.0"},
      "host" => "users.api.com",
      "paths" => %{
        "/users" => %{
          "get" => %{
            "operationId" => "getUsers",
            "responses" => %{"200" => %{"description" => "OK"}}
          }
        }
      }
    }

    spec2 = %{
      "swagger" => "2.0",
      "info" => %{"title" => "Product API", "version" => "1.0.0"},
      "host" => "products.api.com",
      "paths" => %{
        "/products" => %{
          "get" => %{
            "operationId" => "getProducts",
            "responses" => %{"200" => %{"description" => "OK"}}
          }
        }
      }
    }

    case OpenApiConverter.convert_multiple([spec1, spec2], prefix: "multi") do
      {:ok, manual} ->
        IO.puts("✓ Successfully converted multiple specs")
        IO.puts("  Manual: #{manual.name}")
        IO.puts("  Tools generated: #{length(manual.tools)}")

        Enum.each(manual.tools, fn tool ->
          IO.puts("    - #{tool.name}")
        end)
      {:error, reason} ->
        IO.puts("✗ Failed to convert specs: #{reason}")
    end

    IO.puts("")
  end

  defp example_5 do
    IO.puts("5. Validating OpenAPI spec...")

    valid_spec = %{
      "swagger" => "2.0",
      "info" => %{"title" => "Test API", "version" => "1.0.0"},
      "host" => "api.example.com",
      "paths" => %{
        "/test" => %{
          "get" => %{
            "operationId" => "test",
            "responses" => %{"200" => %{"description" => "OK"}}
          }
        }
      }
    }

    invalid_spec = %{"invalid" => "spec"}

    # Validate valid spec
    case OpenApiConverter.validate(valid_spec) do
      {:ok, result} ->
        IO.puts("✓ Valid spec validation:")
        IO.puts("  Valid: #{result.valid}")
        IO.puts("  Version: #{result.version}")
        IO.puts("  Operations: #{result.operations_count}")
        IO.puts("  Security schemes: #{result.security_schemes_count}")
      {:error, reason} ->
        IO.puts("✗ Validation failed: #{reason}")
    end

    # Validate invalid spec
    case OpenApiConverter.validate(invalid_spec) do
      {:ok, result} ->
        IO.puts("✓ Invalid spec validation:")
        IO.puts("  Valid: #{result.valid}")
        IO.puts("  Errors: #{length(result.errors)}")
        if length(result.errors) > 0 do
          IO.puts("  First error: #{List.first(result.errors).message}")
        end
      {:error, reason} ->
        IO.puts("✗ Validation failed: #{reason}")
    end

    IO.puts("")
  end
end

# Run the example
OpenApiConverterExample.run()
