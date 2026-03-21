1. README.md
Markdown# Factory HR & Attendance

Modern Flutter + Supabase application for factory workforce management  
(focusing on employee management, attendance, leave approval, department structure, role-based access)

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-blue.svg)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.0+-green.svg)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.5+-purple.svg)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Features (implemented so far)

- Email + Password authentication (with active/inactive status check)
- Role-based dashboard & menu visibility
- Admin features:
  - Manage divisions (bộ phận)
  - Manage departments (phòng ban)
  - Manage employees (CRUD + activate/deactivate + permanent delete via Edge Function)
  - Role permissions configuration
  - Role hierarchy (who reports to whom)
- Attendance & Leave:
  - Personal timesheet view (worker)
  - Manager attendance view
  - Leave request & approval flow
- Responsive layout (mobile + tablet/web friendly views)

## Tech Stack

- Flutter 3.24+
- Riverpod 2.5+ (state management)
- Supabase Flutter SDK
- Supabase Edge Functions (create/delete employee with admin rights)
- flutter_dotenv (environment variables)
- Material 3 design

## Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/factory-hr-attendance.git
   cd factory-hr-attendance

Install dependenciesBashflutter pub get
Create .env file in root (or rename ungdung.env):textSUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
Run the appBashflutter run

Folder Structure (main parts)
textlib/
├── core/                     # global services, exceptions, providers
├── features/
│   ├── auth/                 # login, register, auth state
│   ├── admin/                # department, division, employee, role config
│   ├── attendance/           # timesheet, leave, manager view
│   └── home/                 # main dashboard + role-based menu
└── main.dart
Supabase Setup Notes

Tables: profiles, divisions, departments, role_permissions, role_hierarchy
Edge Functions: create_employee, delete_employee
RLS should be enabled (especially on profiles)

Next milestones (rough plan)

Production / manufacturing log
Inventory / material management
Report & statistic dashboard
Offline support (basic caching)
Multi-language (VN/EN)
Push notifications for leave approval

License
MIT License
text### 2. ARCHITECTURE.md

```markdown
# Architecture Overview

## Design Principles

- Feature-first folder structure
- Clean separation: controllers (Riverpod), repositories, views
- Heavy use of Riverpod providers for data fetching & business logic
- Supabase as single source of truth (PostgreSQL + Auth + Edge Functions)

## Folder Structure
lib/
├── core/
│   ├── exceptions/
│   └── services/
├── features/
│   ├── auth/
│   │   ├── controllers/
│   │   ├── repositories/
│   │   └── views/
│   ├── admin/
│   │   ├── controllers/
│   │   └── views/
│   ├── attendance/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── views/
│   └── home/
└── main.dart
text## State Management

- **Riverpod 2.x** — used everywhere
  - `FutureProvider` / `StreamProvider` for data fetching
  - `StateNotifierProvider` / `Provider` for actions
  - `ref.invalidate()` + `ref.watch()` pattern

## Data Layer

- Direct Supabase client usage in most places
- Edge Functions used for critical admin operations:
  - `create_employee` → create auth user + profile
  - `delete_employee` → delete auth user

## Security

- Supabase Auth + custom `is_active` flag in `profiles`
- Role-based UI rendering (via `role_permissions` table)
- Edge Functions run with service_role key (admin rights)

## Current Limitations

- No offline support yet
- No input validation in many forms
- Minimal error handling & user feedback
- No unit/widget tests
- No proper loading / error states in some screens

## Planned Improvements

- Repository pattern consistency
- Form validation + state management for forms
- Better error boundary & snackbar system
- RLS policy documentation
- Feature flags / module enable/disable
3. TODO.md
Markdown# TODO - Factory HR & Attendance

## High Priority (critical fixes / security)

- [ ] Add proper RLS policies on all tables (especially profiles, attendance)
- [ ] Input validation + error messages on all forms
- [ ] Prevent self-deletion / admin lockout in employee delete flow
- [ ] Fix delete_employee edge function — currently doesn't delete profile row

## Must-have before production

- [ ] Leave request submission form (currently incomplete in code)
- [ ] Manager can approve/reject leave requests
- [ ] Timesheet / attendance record creation (daily check-in)
- [ ] Search & filter improvement in employee list
- [ ] Loading & error states everywhere

## Medium Priority (good to have)

- [ ] Vietnamese localization (strings)
- [ ] Dark mode support
- [ ] Responsive layout fixes for very small screens
- [ ] Profile edit (self-service for phone, avatar, etc.)
- [ ] Password change / reset flow
- [ ] Activity log / audit trail (who changed what)

## Nice-to-have / Future modules

- [ ] Production log / nhật ký sản xuất
- [ ] Inventory / vật tư management
- [ ] Asset / tài sản management
- [ ] Report dashboard (KPI, attendance stats, leave balance)
- [ ] Export Excel/PDF reports
- [ ] Push notifications (leave approved/rejected)
- [ ] Offline caching (Hive or similar)

Last updated: 2026-03
4. CONTEXT.md
Markdown# Project Context

## Business Goal

Digital transformation for small-medium Vietnamese factories:

- Replace paper timesheets & leave requests
- Centralize employee & department information
- Give managers visibility & approval power
- Reduce admin workload on HR tasks
- Prepare foundation for full ERP (production, inventory, reports)

## Target Users

1. Admin / HR Manager
   - Manage structure (divisions, departments)
   - CRUD employees
   - Configure roles & permissions

2. Department/Team Manager
   - View team attendance
   - Approve/reject leave requests

3. Office Staff / Worker
   - View personal timesheet
   - Submit leave requests

## Current Scope (MVP)

- Authentication & role-based access
- Organization structure (divisions + departments)
- Employee management (basic CRUD + status)
- Role & permission configuration
- Basic leave request view (incomplete)

## Non-functional Requirements (target)

- Support ~200–500 users
- Mobile-first (factory workers mostly use phones)
- Vietnamese language primary
- Data must be reasonably secure (RLS + edge function isolation)
- Fast CRUD operations (< 1–2s)

## Success Criteria (MVP)

- Workers can see their own attendance & submit leave
- Managers can approve leave
- Admin can add/remove employees safely
- No critical security holes (self-escalation, data leak)

Current progress: ~45–55% of MVP
5. PROGRESS.md
Markdown# Development Progress Log

**Project name**: Factory HR & Attendance  
**Last updated**: March 2026

## Completed

- Supabase setup + auth flow (email/password)
- Active/inactive user check on login
- Role-based dashboard menu
- Division & Department CRUD
- Employee list + search/filter + edit + activate/deactivate
- Role permissions (feature toggle per role)
- Role hierarchy (reports-to configuration)
- Edge Functions: create_employee, delete_employee (partial)
- Basic responsive layout (DataTable on web/tablet, Cards on mobile)

## In Progress / Partially done

- Leave request form & approval screen
- Manager attendance view
- Personal timesheet view

## Not started yet

- Actual attendance recording (check-in/out)
- Leave balance calculation
- Notification system
- Reports & statistics
- Production / inventory modules

## Known Issues / Technical Debt

- delete_employee function doesn't delete profile row
- No form validation in most places
- Incomplete leave flow
- Missing RLS documentation & verification
- No tests
- Error handling is minimal

## Next 2–4 weeks target

1. Complete leave request + approval flow
2. Implement daily attendance check-in
3. Add basic RLS policies
4. Improve UX (loading states, better messages)
5. Vietnamese translation of UI strings

Feel free to create issues / PRs for any of the above items.