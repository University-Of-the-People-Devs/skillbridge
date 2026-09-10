-- ============================================================
-- SkillBridge
-- Initial Database Schema
-- Migration: 0001_initial_schema.sql
-- ============================================================

-- ============================================================
-- EXTENSIONS
-- ============================================================

create extension if not exists "pgcrypto";

-- ============================================================
-- ENUM TYPES
-- ============================================================

create type public.project_status as enum (
'planning',
'recruiting',
'active',
'paused',
'completed',
'archived'
);

create type public.project_visibility as enum (
'public',
'private'
);

create type public.application_status as enum (
'pending',
'accepted',
'rejected',
'withdrawn'
);

create type public.project_member_status as enum (
'active',
'inactive'
);

create type public.contribution_type as enum (
'commit',
'pull_request',
'issue',
'code_review',
'other'
);

create type public.notification_type as enum (
'project_application',
'application_accepted',
'application_rejected',
'project_invitation',
'team_update',
'project_update',
'github_activity',
'system'
);

-- ============================================================
-- PROFILES
-- ============================================================

create table public.profiles (
id uuid primary key references auth.users(id) on delete cascade,

username text unique,
full_name text,
avatar_url text,
bio text,

location text,
country text,

education text,
experience text,

github_url text,
portfolio_url text,
linkedin_url text,
website_url text,

created_at timestamptz not null default now(),
updated_at timestamptz not null default now()
);

-- ============================================================
-- SKILLS
-- ============================================================

create table public.skills (
id uuid primary key default gen_random_uuid(),

name text not null unique,
category text,
description text,

created_at timestamptz not null default now(),
updated_at timestamptz not null default now()
);

-- ============================================================
-- USER SKILLS
-- ============================================================

create table public.user_skills (
id uuid primary key default gen_random_uuid(),

user_id uuid not null references public.profiles(id) on delete cascade,
skill_id uuid not null references public.skills(id) on delete cascade,

proficiency_level text,
years_experience numeric(4,1),

created_at timestamptz not null default now(),

unique(user_id, skill_id)
);

-- ============================================================
-- PROJECTS
-- ============================================================

create table public.projects (
id uuid primary key default gen_random_uuid(),

owner_id uuid not null references public.profiles(id) on delete restrict,

name text not null,
slug text unique,

description text,
problem_statement text,
goals text,

category text,

status public.project_status not null default 'planning',

team_size integer,

repository_url text,

visibility public.project_visibility not null default 'public',

created_at timestamptz not null default now(),
updated_at timestamptz not null default now(),

constraint projects_team_size_positive
check (team_size is null or team_size > 0)
);

-- ============================================================
-- PROJECT SKILLS
-- ============================================================

create table public.project_skills (
id uuid primary key default gen_random_uuid(),

project_id uuid not null references public.projects(id) on delete cascade,
skill_id uuid not null references public.skills(id) on delete cascade,

importance text,

created_at timestamptz not null default now(),

unique(project_id, skill_id)
);

-- ============================================================
-- PROJECT MEMBERS
-- ============================================================

create table public.project_members (
id uuid primary key default gen_random_uuid(),

project_id uuid not null references public.projects(id) on delete cascade,
user_id uuid not null references public.profiles(id) on delete cascade,

role text not null default 'contributor',
responsibility text,

joined_at timestamptz not null default now(),

status public.project_member_status not null default 'active',

unique(project_id, user_id)
);

-- ============================================================
-- PROJECT APPLICATIONS
-- ============================================================

create table public.project_applications (
id uuid primary key default gen_random_uuid(),

project_id uuid not null references public.projects(id) on delete cascade,
applicant_id uuid not null references public.profiles(id) on delete cascade,

message text,
proposed_role text,

status public.application_status not null default 'pending',

reviewed_by uuid references public.profiles(id) on delete set null,
reviewed_at timestamptz,

created_at timestamptz not null default now(),
updated_at timestamptz not null default now(),

unique(project_id, applicant_id)
);

-- ============================================================
-- GITHUB ACCOUNTS
-- ============================================================

create table public.github_accounts (
id uuid primary key default gen_random_uuid(),

user_id uuid not null unique references public.profiles(id) on delete cascade,

github_user_id text not null unique,
github_username text not null,
profile_url text,

connected_at timestamptz not null default now(),
updated_at timestamptz not null default now()
);

-- ============================================================
-- GITHUB REPOSITORIES
-- ============================================================

create table public.github_repositories (
id uuid primary key default gen_random_uuid(),

project_id uuid not null references public.projects(id) on delete cascade,

github_repository_id text not null unique,
repository_name text not null,
repository_url text not null,

owner text,
description text,

connected_at timestamptz not null default now(),
updated_at timestamptz not null default now()
);

-- ============================================================
-- CONTRIBUTIONS
-- ============================================================

create table public.contributions (
id uuid primary key default gen_random_uuid(),

project_id uuid not null references public.projects(id) on delete cascade,
user_id uuid not null references public.profiles(id) on delete cascade,
repository_id uuid references public.github_repositories(id) on delete set null,

contribution_type public.contribution_type not null,

external_id text,
title text,
description text,
contribution_url text,

contribution_date timestamptz,

metadata jsonb,

created_at timestamptz not null default now()
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================

create table public.notifications (
id uuid primary key default gen_random_uuid(),

user_id uuid not null references public.profiles(id) on delete cascade,

type public.notification_type not null,

title text not null,
message text,

reference_type text,
reference_id uuid,

is_read boolean not null default false,

created_at timestamptz not null default now()
);

-- ============================================================
-- INDEXES
-- ============================================================

create index idx_profiles_country
on public.profiles(country);

create index idx_profiles_username
on public.profiles(username);

create index idx_skills_name
on public.skills(name);

create index idx_skills_category
on public.skills(category);

create index idx_user_skills_user
on public.user_skills(user_id);

create index idx_user_skills_skill
on public.user_skills(skill_id);

create index idx_projects_owner
on public.projects(owner_id);

create index idx_projects_status
on public.projects(status);

create index idx_projects_category
on public.projects(category);

create index idx_projects_visibility
on public.projects(visibility);

create index idx_project_skills_project
on public.project_skills(project_id);

create index idx_project_skills_skill
on public.project_skills(skill_id);

create index idx_project_members_project
on public.project_members(project_id);

create index idx_project_members_user
on public.project_members(user_id);

create index idx_project_applications_project
on public.project_applications(project_id);

create index idx_project_applications_applicant
on public.project_applications(applicant_id);

create index idx_project_applications_status
on public.project_applications(status);

create index idx_github_accounts_user
on public.github_accounts(user_id);

create index idx_github_repositories_project
on public.github_repositories(project_id);

create index idx_contributions_project
on public.contributions(project_id);

create index idx_contributions_user
on public.contributions(user_id);

create index idx_contributions_repository
on public.contributions(repository_id);

create index idx_notifications_user
on public.notifications(user_id);

create index idx_notifications_unread
on public.notifications(user_id, is_read);

-- ============================================================
-- UPDATED_AT TRIGGER FUNCTION
-- ============================================================

create or replace function public.update_updated_at_column()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
new.updated_at = now();
return new;
end;

$$$;


-- ============================================================
-- UPDATED_AT TRIGGERS
-- ============================================================

create trigger update_profiles_updated_at
before update on public.profiles
for each row
execute function public.update_updated_at_column();

create trigger update_skills_updated_at
before update on public.skills
for each row
execute function public.update_updated_at_column();

create trigger update_projects_updated_at
before update on public.projects
for each row
execute function public.update_updated_at_column();

create trigger update_project_applications_updated_at
before update on public.project_applications
for each row
execute function public.update_updated_at_column();

create trigger update_github_accounts_updated_at
before update on public.github_accounts
for each row
execute function public.update_updated_at_column();

create trigger update_github_repositories_updated_at
before update on public.github_repositories
for each row
execute function public.update_updated_at_column();


-- ============================================================
-- AUTOMATIC PROFILE CREATION
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (
    id,
    full_name,
    avatar_url
  )
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    new.raw_user_meta_data ->> 'avatar_url'
  );

  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();


-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

alter table public.profiles enable row level security;
alter table public.skills enable row level security;
alter table public.user_skills enable row level security;
alter table public.projects enable row level security;
alter table public.project_skills enable row level security;
alter table public.project_members enable row level security;
alter table public.project_applications enable row level security;
alter table public.github_accounts enable row level security;
alter table public.github_repositories enable row level security;
alter table public.contributions enable row level security;
alter table public.notifications enable row level security;


-- ============================================================
-- PROFILES POLICIES
-- ============================================================

create policy "Public profiles are viewable"
on public.profiles
for select
using (true);

create policy "Users can update their own profile"
on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);


-- ============================================================
-- SKILLS POLICIES
-- ============================================================

create policy "Skills are publicly viewable"
on public.skills
for select
using (true);


-- ============================================================
-- USER SKILLS POLICIES
-- ============================================================

create policy "User skills are publicly viewable"
on public.user_skills
for select
using (true);

create policy "Users can add their own skills"
on public.user_skills
for insert
with check (auth.uid() = user_id);

create policy "Users can remove their own skills"
on public.user_skills
for delete
using (auth.uid() = user_id);


-- ============================================================
-- PROJECT POLICIES
-- ============================================================

create policy "Public projects are viewable"
on public.projects
for select
using (
  visibility = 'public'
  or owner_id = auth.uid()
);

create policy "Authenticated users can create projects"
on public.projects
for insert
to authenticated
with check (owner_id = auth.uid());

create policy "Owners can update their projects"
on public.projects
for update
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "Owners can delete their projects"
on public.projects
for delete
using (owner_id = auth.uid());


-- ============================================================
-- PROJECT SKILLS POLICIES
-- ============================================================

create policy "Project skills are viewable"
on public.project_skills
for select
using (true);

create policy "Project owners can add project skills"
on public.project_skills
for insert
with check (
  exists (
    select 1
    from public.projects
    where projects.id = project_skills.project_id
      and projects.owner_id = auth.uid()
  )
);

create policy "Project owners can remove project skills"
on public.project_skills
for delete
using (
  exists (
    select 1
    from public.projects
    where projects.id = project_skills.project_id
      and projects.owner_id = auth.uid()
  )
);


-- ============================================================
-- PROJECT MEMBERS POLICIES
-- ============================================================

create policy "Project members are viewable"
on public.project_members
for select
using (true);

create policy "Project owners can add members"
on public.project_members
for insert
with check (
  exists (
    select 1
    from public.projects
    where projects.id = project_members.project_id
      and projects.owner_id = auth.uid()
  )
);

create policy "Project owners can update members"
on public.project_members
for update
using (
  exists (
    select 1
    from public.projects
    where projects.id = project_members.project_id
      and projects.owner_id = auth.uid()
  )
);

create policy "Project owners can remove members"
on public.project_members
for delete
using (
  exists (
    select 1
    from public.projects
    where projects.id = project_members.project_id
      and projects.owner_id = auth.uid()
  )
);


-- ============================================================
-- PROJECT APPLICATION POLICIES
-- ============================================================

create policy "Applicants can view their own applications"
on public.project_applications
for select
using (
  applicant_id = auth.uid()
  or exists (
    select 1
    from public.projects
    where projects.id = project_applications.project_id
      and projects.owner_id = auth.uid()
  )
);

create policy "Users can apply to projects"
on public.project_applications
for insert
to authenticated
with check (applicant_id = auth.uid());

create policy "Applicants can withdraw their applications"
on public.project_applications
for update
using (applicant_id = auth.uid())
with check (applicant_id = auth.uid());

create policy "Project owners can review applications"
on public.project_applications
for update
using (
  exists (
    select 1
    from public.projects
    where projects.id = project_applications.project_id
      and projects.owner_id = auth.uid()
  )
);

create policy "Applicants can delete their applications"
on public.project_applications
for delete
using (applicant_id = auth.uid());


-- ============================================================
-- GITHUB ACCOUNT POLICIES
-- ============================================================

create policy "Users can view their GitHub account"
on public.github_accounts
for select
using (user_id = auth.uid());

create policy "Users can connect their GitHub account"
on public.github_accounts
for insert
with check (user_id = auth.uid());

create policy "Users can update their GitHub account"
on public.github_accounts
for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "Users can remove their GitHub account"
on public.github_accounts
for delete
using (user_id = auth.uid());


-- ============================================================
-- GITHUB REPOSITORY POLICIES
-- ============================================================

create policy "Project repositories are viewable"
on public.github_repositories
for select
using (true);

create policy "Project owners can add repositories"
on public.github_repositories
for insert
with check (
  exists (
    select 1
    from public.projects
    where projects.id = github_repositories.project_id
      and projects.owner_id = auth.uid()
  )
);

create policy "Project owners can update repositories"
on public.github_repositories
for update
using (
  exists (
    select 1
    from public.projects
    where projects.id = github_repositories.project_id
      and projects.owner_id = auth.uid()
  )
);

create policy "Project owners can delete repositories"
on public.github_repositories
for delete
using (
  exists (
    select 1
    from public.projects
    where projects.id = github_repositories.project_id
      and projects.owner_id = auth.uid()
  )
);


-- ============================================================
-- CONTRIBUTION POLICIES
-- ============================================================

create policy "Contributions are publicly viewable"
on public.contributions
for select
using (true);


-- ============================================================
-- NOTIFICATION POLICIES
-- ============================================================

create policy "Users can view their notifications"
on public.notifications
for select
using (user_id = auth.uid());

create policy "Users can mark their notifications as read"
on public.notifications
for update
using (user_id = auth.uid())
with check (user_id = auth.uid());


-- ============================================================
-- END OF INITIAL MIGRATION
-- ============================================================
$$$
