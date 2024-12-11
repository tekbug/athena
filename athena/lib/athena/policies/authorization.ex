defmodule Athena.Policies.Authorization do
  @moduledoc """
  Central authorization policy module implementing role-based access control (RBAC)
  with additional attribute-based access control (ABAC) features.
  """

  alias Athena.Accounts.{User, UserRole}
  alias Athena.Courses.Course
  alias Athena.Classrooms.{VirtualClassroom, ClassroomSession}

  # Role hierarchies
  @role_hierarchy %{
    "institution_admin" => ["admin", "teacher", "student"],
    "admin" => ["teacher", "student"],
    "teacher" => ["student"],
    "student" => []
  }

  # Permission sets
  @permissions %{
    institutions: [:create, :read, :update, :delete, :manage_users],
    courses: [:create, :read, :update, :delete, :enroll, :manage_enrollment],
    classrooms: [:create, :read, :update, :delete, :join, :manage_sessions],
    assignments: [:create, :read, :update, :delete, :submit, :grade],
    users: [:create, :read, :update, :delete, :manage_roles]
  }

  @doc """
  Checks if a user has permission to perform an action
  """
  @spec authorize(User.t(), atom(), atom(), map()) :: boolean()
  def authorize(user, resource, action, context \\ %{}) do
    with {:ok, roles} <- get_user_roles(user),
         true <- has_permission?(roles, resource, action),
         true <- check_additional_rules(user, resource, action, context) do
      true
    else
      _ -> false
    end
  end

  @doc """
  Checks if a user has a specific role
  """
  @spec has_role?(User.t(), String.t()) :: boolean()
  def has_role?(user, role) do
    user.user_roles
    |> Enum.any?(fn ur -> ur.role_types == role end)
  end

  @doc """
  Gets all effective roles for a user including inherited roles
  """
  @spec get_effective_roles(User.t()) :: {:ok, [String.t()]} | {:error, term()}
  def get_effective_roles(user) do
    with {:ok, direct_roles} <- get_user_roles(user) do
      effective_roles =
        direct_roles
        |> Enum.flat_map(fn role -> [role | get_inherited_roles(role)] end)
        |> Enum.uniq()

      {:ok, effective_roles}
    end
  end

  # Private functions

  defp get_user_roles(user) do
    roles =
      user.user_roles
      |> Enum.map(& &1.role_types)

    {:ok, roles}
  end

  defp has_permission?(roles, resource, action) do
    Enum.any?(roles, fn role ->
      role_has_permission?(role, resource, action)
    end)
  end

  defp role_has_permission?(role, resource, action) do
    case get_role_permissions(role) do
      {:ok, permissions} ->
        resource_permissions = Map.get(permissions, resource, [])
        action in resource_permissions

      _ ->
        false
    end
  end

  defp get_role_permissions("institution_admin") do
    {:ok, @permissions}
  end

  defp get_role_permissions("admin") do
    permissions =
      @permissions
      |> Map.drop([:institutions])

    {:ok, permissions}
  end

  defp get_role_permissions("teacher") do
    {:ok,
     %{
       courses: [:read, :update],
       classrooms: [:read, :create, :update, :manage_sessions],
       assignments: [:create, :read, :update, :grade]
     }}
  end

  defp get_role_permissions("student") do
    {:ok,
     %{
       courses: [:read],
       classrooms: [:read, :join],
       assignments: [:read, :submit]
     }}
  end

  defp get_inherited_roles(role) do
    Map.get(@role_hierarchy, role, [])
  end

  defp check_additional_rules(user, resource, action, context) do
    case {resource, action} do
      {:courses, _} ->
        check_course_rules(user, action, context)

      {:classrooms, _} ->
        check_classroom_rules(user, action, context)

      {:assignments, _} ->
        check_assignment_rules(user, action, context)

      _ ->
        true
    end
  end

  defp check_course_rules(user, action, %{course: course}) do
    cond do
      has_role?(user, "teacher") && course.teacher_id == user.id ->
        true

      has_role?(user, "student") && is_enrolled?(user, course) ->
        action in [:read, :submit]

      true ->
        false
    end
  end

  defp check_course_rules(_, _, _), do: true

  defp check_classroom_rules(user, action, %{classroom: classroom}) do
    cond do
      has_role?(user, "teacher") && classroom.teacher_id == user.id ->
        true

      has_role?(user, "student") && is_enrolled?(user, classroom.course) ->
        action in [:read, :join]

      true ->
        false
    end
  end

  defp check_classroom_rules(_, _, _), do: true

  defp check_assignment_rules(user, action, %{assignment: assignment}) do
    cond do
      has_role?(user, "teacher") && assignment.course.teacher_id == user.id ->
        true

      has_role?(user, "student") ->
        check_student_assignment_rules(user, action, assignment)

      true ->
        false
    end
  end

  defp check_assignment_rules(_, _, _), do: true

  defp check_student_assignment_rules(user, :submit, assignment) do
    is_enrolled?(user, assignment.course) &&
      not is_past_due?(assignment) &&
      not has_submitted?(user, assignment)
  end

  defp check_student_assignment_rules(user, :read, assignment) do
    is_enrolled?(user, assignment.course)
  end

  defp check_student_assignment_rules(_, _, _), do: false

  defp is_enrolled?(user, course) do
    true
  end

  defp is_past_due?(assignment) do
    DateTime.compare(DateTime.utc_now(), assignment.due_date) == :gt
  end

  defp has_submitted?(user, assignment) do
    false
  end
end
