# SkillBridge Database Schema

## 1. Purpose

This document defines the initial database structure for SkillBridge.

The database will use PostgreSQL through Supabase.

The schema is designed to support the MVP while remaining flexible enough for future features such as AI matching, reputation, opportunities, organizations, and mobile applications.

---

# 2. Database Principles

The database should follow these principles:

* Use relational PostgreSQL tables.
* Use UUIDs for primary keys where appropriate.
* Maintain clear relationships between entities.
* Avoid unnecessary duplication of data.
* Use foreign keys to maintain data integrity.
* Use timestamps for important records.
* Use Row Level Security (RLS).
* Never expose sensitive information unnecessarily.
* Keep the schema extensible.
* Avoid hard-coding business rules that may change.

---

# 3. Core Tables

The initial database will contain the following major entities:

```text
profiles
skills
user_skills
projects
project_skills
project_members
project_applications
github_accounts
github_repositories
contributions
notifications
```

Additional tables may be introduced as the platform evolves.

---

# 4. Profiles

## Table: profiles

Stores the public professional profile of each SkillBridge user.

### Fields

* id
* username
* full_name
* avatar_url
* bio
* location
* country
* education
* experience
* github_url
* portfolio_url
* linkedin_url
* website_url
* created_at
* updated_at

### Relationships

```text
auth.users
    ↓
profiles
```

Each authenticated user should have one primary profile.

---

# 5. Skills

## Table: skills

Stores available skills on the platform.

### Fields

* id
* name
* category
* description
* created_at
* updated_at

Skills should be database-managed rather than permanently hard-coded into the frontend.

Examples:

* JavaScript
* TypeScript
* React
* Next.js
* Python
* Java
* C++
* UI/UX Design
* Data Science
* Machine Learning
* Cybersecurity
* DevOps

---

# 6. User Skills

## Table: user_skills

Creates the relationship between users and their skills.

### Fields

* id
* user_id
* skill_id
* proficiency_level
* years_experience
* created_at

### Relationship

```text
profiles
    ↓
user_skills
    ↓
skills
```

This allows one user to have multiple skills and one skill to belong to multiple users.

---

# 7. Projects

## Table: projects

Stores projects created on SkillBridge.

### Fields

* id
* owner_id
* name
* slug
* description
* problem_statement
* goals
* category
* status
* team_size
* repository_url
* visibility
* created_at
* updated_at

### Possible project statuses

* Planning
* Recruiting
* Active
* Paused
* Completed
* Archived

Project status values should be managed consistently across the application.

---

# 8. Project Skills

## Table: project_skills

Defines the skills required by a project.

### Fields

* id
* project_id
* skill_id
* importance
* created_at

### Relationship

```text
projects
    ↓
project_skills
    ↓
skills
```

This allows SkillBridge to determine which skills are required by each project.

---

# 9. Project Members

## Table: project_members

Stores users who are members of a project.

### Fields

* id
* project_id
* user_id
* role
* responsibility
* joined_at
* status

### Possible roles

* Owner
* Project Manager
* Developer
* Designer
* Researcher
* Contributor
* Other

Roles should remain configurable as the platform evolves.

---

# 10. Project Applications

## Table: project_applications

Stores applications from users who want to join projects.

### Fields

* id
* project_id
* applicant_id
* message
* proposed_role
* status
* reviewed_by
* reviewed_at
* created_at
* updated_at

### Possible statuses

* Pending
* Accepted
* Rejected
* Withdrawn

### Relationship

```text
User
  ↓
Project Application
  ↓
Project
```

---

# 11. GitHub Accounts

## Table: github_accounts

Stores the connection between a SkillBridge user and their GitHub account.

### Fields

* id
* user_id
* github_user_id
* github_username
* profile_url
* connected_at
* updated_at

Sensitive GitHub authentication credentials or tokens must never be stored in publicly accessible database fields.

---

# 12. GitHub Repositories

## Table: github_repositories

Stores repositories connected to SkillBridge projects.

### Fields

* id
* project_id
* github_repository_id
* repository_name
* repository_url
* owner
* description
* connected_at
* updated_at

---

# 13. Contributions

## Table: contributions

Stores verified development activity associated with SkillBridge projects.

### Fields

* id
* project_id
* user_id
* repository_id
* contribution_type
* external_id
* title
* description
* contribution_url
* contribution_date
* metadata
* created_at

### Possible contribution types

* Commit
* Pull Request
* Issue
* Code Review
* Other

The contribution system should focus on evidence of real project participation.

---

# 14. Notifications

## Table: notifications

Stores user notifications.

### Fields

* id
* user_id
* type
* title
* message
* reference_type
* reference_id
* is_read
* created_at

Notifications may be generated for:

* Project invitations.
* Application decisions.
* New project applications.
* Team changes.
* Project updates.
* GitHub activity.
* Opportunities.
* System announcements.

---

# 15. Future Tables

The following tables may be introduced after the MVP:

```text
reputation
badges
reviews
opportunities
opportunity_applications
organizations
organization_members
universities
university_members
messages
conversations
project_tasks
project_milestones
subscriptions
payments
ai_recommendations
```

These should not be implemented until their requirements are clearly defined.

---

# 16. Core Relationships

The initial relationship structure can be represented as:

```text
                    ┌──────────────┐
                    │ auth.users   │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   profiles   │
                    └──────┬───────┘
                           │
                  ┌────────┴────────┐
                  ▼                 ▼
            user_skills        projects
                  │                 │
                  ▼          ┌──────┼───────┐
               skills         │      │       │
                             ▼      ▼       ▼
                       project_  project_  project_
                       skills   members applications
                                  │
                                  ▼
                               profiles

projects
   │
   ▼
github_repositories
   │
   ▼
contributions
   │
   ▼
profiles
```

---

# 17. Security and Row Level Security

Supabase Row Level Security (RLS) must be enabled on all user-related tables.

The system should ensure that:

* Users can update their own profiles.
* Users cannot modify another user's profile without authorization.
* Users can manage projects they own.
* Project members can access information required for their project.
* Project applications are visible only to authorized users.
* Users can access their own notifications.
* Contribution records cannot be arbitrarily modified by users.
* Administrative actions require appropriate authorization.

Security policies must be tested before production deployment.

---

# 18. Data Integrity

Foreign keys should be used wherever relationships exist.

Important relationships include:

```text
profiles.id → auth.users.id

user_skills.user_id → profiles.id

user_skills.skill_id → skills.id

projects.owner_id → profiles.id

project_skills.project_id → projects.id

project_skills.skill_id → skills.id

project_members.project_id → projects.id

project_members.user_id → profiles.id

project_applications.project_id → projects.id

project_applications.applicant_id → profiles.id

github_accounts.user_id → profiles.id

github_repositories.project_id → projects.id

contributions.project_id → projects.id

contributions.user_id → profiles.id

notifications.user_id → profiles.id
```

---

# 19. Indexing

Indexes should be added to fields frequently used for:

* Searching.
* Filtering.
* Sorting.
* Joining.
* Authentication-related queries.

Potential indexes include:

* profiles.username
* profiles.country
* skills.name
* projects.owner_id
* projects.status
* projects.category
* project_members.project_id
* project_members.user_id
* project_applications.project_id
* project_applications.applicant_id
* contributions.user_id
* contributions.project_id
* notifications.user_id

Indexes should be added based on actual query requirements and performance testing.

---

# 20. Auditability

Important system actions should be traceable.

Future audit functionality may record:

* User creation.
* Project creation.
* Project ownership changes.
* Team membership changes.
* Application decisions.
* Administrative changes.
* Security-sensitive actions.

Audit logging should be expanded as the platform becomes more mature.

---

# 21. Database Evolution

The database will evolve over time.

All schema changes should:

* Be documented.
* Use migrations.
* Be tested before deployment.
* Avoid breaking existing functionality.
* Preserve existing user data.
* Include rollback considerations where practical.

Direct production database changes should be avoided unless properly reviewed.

---

# 22. Scalability

The initial database should support the MVP without unnecessary complexity.

However, the architecture should allow future growth to:

* Thousands of users.
* Large numbers of projects.
* Large contribution histories.
* International users.
* Organizations.
* Universities.
* Mobile applications.
* AI recommendation systems.

Database optimization should be driven by real usage and measurable performance requirements.

---

# 23. Initial MVP Database Scope

The first implementation should prioritize:

1. profiles
2. skills
3. user_skills
4. projects
5. project_skills
6. project_members
7. project_applications
8. github_accounts
9. github_repositories
10. contributions
11. notifications

Future tables should only be added when their functionality enters development.

---

# 24. Database Design Principle

The SkillBridge database should support the platform's central philosophy:

> **Do not only tell the world what you can do. Build something and prove it.**

The database must therefore preserve the relationship between:

**Users → Skills → Projects → Teams → Contributions → Reputation → Opportunities**

This relationship forms the foundation of SkillBridge's long-term value.
