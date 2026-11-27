# Student Manager WS101 V3 — upgrade instructions

V3 uses plain PHP, HTML/CSS, vanilla JavaScript and MySQL/MariaDB. No frameworks or build step.

## Existing V2 installation

1. Back up the entire database and old project folder. Stop using the old V2 app after switching (its old grade editor does not understand the new periods).
2. In phpMyAdmin select your existing `student_management_ws101` database. Import `database/upgrade_v3.sql`. If coming from V1, apply `database/upgrade_v2.sql` first. Do not import the fresh installation SQL into an existing database.
3. Optional for local demonstration: import `database/curriculum_demo_v3.sql` **after** the upgrade. If you want the earlier HCDC sample data and have not already imported it, import `database/HCDC_WS101_sample_data.sql` before the demo curriculum. These scripts are fictional sample records, not official curricula. The demo script sets missing year levels only for known demo students, adds up to two demo classes for the base demo teacher, and rebalances the known HCI demo assignment if the destination demo teacher has capacity. Existing non-demo class assignments are not changed.
4. Extract the V3 folder into XAMPP htdocs. Preserve your own settings in `config/database.php`. Start Apache and MySQL; open `http://localhost/Student-Manager-WS101-V3/`.
5. In Admin > Students, set each actual student's year level (unknown levels intentionally remain NULL). In Admin > Curriculum, map subject/class to course and year, optionally select a prerequisite. Map prerequisites first. Admin > Classes allows up to 3 assigned subjects per teacher; older overloads remain visible until admin reassigns them.
6. Enrollment staff: search student by name, select them, pick a curriculum year at or below their year level, then check eligible subjects. Already enrolled subjects cannot be added again; recorded grades lock an enrollment against removal. Prerequisites require overall >=75 under the demo policy. No repeat enrollment or academic term functionality is implemented.
7. Teacher: Classes shows assigned subjects and their rosters; Grades searches by student name, with Prelim/Midterm/Finals tabs. Each period accepts all five scores and calculates the weighted result server-side. Overall is the equal average of all three periods, and only appears when all are complete. Legacy overall grades are kept in `grades` and clearly labeled; their previous breakdowns remain accessible. Staff can see grade summaries, but only assigned teachers can edit periods. Students see only their own grades and may click for breakdowns.

## Fresh installation

Import `database/student_management_ws101.sql` once into a NEW database (includes V3 schema). Then optionally import `database/HCDC_WS101_sample_data.sql` and `database/curriculum_demo_v3.sql` in that order. Set config and open the project as above. See historical README below for demo credentials.

## Data and testing notes

New tables: `curriculum_subjects`, `grade_periods`. New nullable `students.year_level`. New view: `grade_summary` derives period and overall grades without overwriting the historical `grades` table. Demo weights remain 40/20/25/10/5 and three periods equally weighted; not verified HCDC policy. No official curriculum or term schedule was provided. Actual MySQL/browser testing remains required; see `docs/V3_TEST_CASES.md`. PHP and pure rule tests can be run via `php tests/grading_test.php` and `php tests/academic_test.php`.

---

## Previous version documentation (historical reference; follow V3 instructions above)

# Student Manager — WS101 edition v2

## Upgrade an existing installation

1. Export a full backup of your current database in phpMyAdmin and copy your current project folder somewhere safe.
2. Select your existing `student_management_ws101` database in phpMyAdmin and import **only** `database/upgrade_v2.sql`. The upgrade extends the staff role and adds five nullable grade component columns; no existing records are overwritten. The script can be retried if interrupted.
3. Extract the v2 ZIP into a separate folder in `htdocs`, or replace the old application files after backing them up. Copy your previous `config/database.php` if you changed the defaults. Do not import the fresh schema into the existing database.
4. Open the new folder URL, sign in as administrator, go to Staff accounts and create an account with the role Enrollment staff. Sign out and sign in using the new account type. No new default staff password is installed.
5. Sign in as teacher, open Grades, select an enrollment and load the grade. Enter actual percentages for the five categories and save. Existing final scores remain intact until you explicitly save a complete breakdown.

For a fresh installation only, use the full schema below. The included HCDC sample data is optional and uses fictional records.

A framework-free PHP 8.1+ / HTML / CSS / vanilla JavaScript and MySQL (or XAMPP MariaDB) conversion of the supplied ADV_104 project. It retains the dark dashboard, student records, classes, courses and grades, with separate student and staff authentication. Add your team members here before submission.

## XAMPP setup (Windows)

1. Extract the ZIP. Copy the `Student-Manager-WS101` folder into `D:\XAMPP\htdocs` (or your own XAMPP `htdocs`). Keep the original application and database as backups.
2. Start Apache and MySQL in XAMPP. If Herd is occupying Apache's port, stop Herd's web server or configure Apache to use a different port.
3. Open `http://localhost/phpmyadmin` and use Import to import `database/student_management_ws101.sql` **once**. This creates a separate database named `student_management_ws101`, not the original `student_management`. If the database already exists with tables, do not rerun the import; use a new empty database or back it up first. If using a limited DB account, have an administrator create the database first and import the schema with the database selected.
4. Open `config/database.php`. The defaults are `127.0.0.1`, port `3306`, database `student_management_ws101`, user `root`, empty password. Update these to your local settings. Make sure PHP's `pdo_mysql` extension is enabled (normally included in XAMPP).
5. Visit `http://localhost/Student-Manager-WS101/`. If Apache uses another port, add it to the URL. No npm, Composer, Laravel, or PowerShell is required.

### Local demo credentials

Select the appropriate account type in the login form.

| Role | Username | Password |
|---|---|---|
| Administrator | admin | AdminDemo!2026 |
| Teacher | teacher | TeacherDemo!2026 |
| Student | student | StudentDemo!2026 |

These are local demonstration credentials only. Change them using My account before any shared deployment. The demo teacher teaches DEMO101, and the demo student is enrolled in that class. The demo student has an initial grade of 90. Use the teacher account to enter all five component percentages, then sign in as the student to verify.

## Features and permissions

- Administrator: CRUD students, courses, classes and staff; assign teachers to classes, enroll students, issue student activation codes, reset or disable student accounts, view all grades, export grades CSV, view audit history.
- Teacher: view only assigned classes and their enrolled students; add, edit and delete grades for those enrollments. No account management. The final grade is a weighted percentage per enrollment, computed in PHP from five assessment percentages. No term/semester model added.
- Enrollment staff: read-only student directory, class catalog and final grade records; enroll students in one or more existing subjects, and remove only ungraded enrollments. No access to grade editing, account administration, course/class editing or CSV export.
- Student: view own profile, enrolled classes and grades only; change own password. No grade writing.
- Administrator can view all grades but cannot write grades, honoring the explicit teacher-only rule. Administrators can assign teachers and manage accounts; a teacher can enter a grade only for an enrolled student in a class assigned to that teacher.
- Registration is controlled: admin opens Student accounts, issues a 24-hour one-time code for a specific student, shares it privately, then student selects Activate student account on the login page. Staff creation is administrator-only.
- A record with dependent enrollments, grades or assigned classes cannot be deleted until those dependencies are handled. Disable staff instead of deleting historical grade authors.

## Source migration decisions

The RAR includes `student_management-2.sql`. It already contained a single students table with a gender enum; male/female were not separate physical tables. The new UI has one student list. All three original student records and both grades are retained, including the student record named Admin (not treated as a staff account). The empty courses table is populated from the original course names. The old classes row is ADV1021 with teacher text Faith, but both grades reference ADV102. The new schema preserves ADV1021 and introduces an unassigned ADV102 placeholder with both original grades connected by student ID. Confirm the course-code mapping and teacher identity with your team, then assign the actual teacher via Classes. The original user table did not contain roles or student IDs and included one plaintext password; those accounts were not migrated or granted permissions. Issue new activation codes or create staff accounts after verifying identity. Existing user passwords are not copied. Demo records are separately labeled.

## Security and course requirements

`config/database.php` central PDO connection; `includes/functions.php` reusable parameterized helpers, validation, escaping, error logging; `includes/auth.php` password verification, role checks, session handling; `index.php` route authorization and CSRF; `pages/` HTML GET/POST forms, role-specific queries and CRUD; `database/` SQL export with sample data; `logs/error.log` technical error logging (created on error); `pages/export.php` CSV file handling; `docs/TEST_CASES.md` local verification checklist. Passwords use password_hash/password_verify. Sessions regenerate on login and invalidate on password changes. Username-only remember cookie. All data queries use prepared PDO statements, user content is HTML escaped. `.htaccess` denies direct web access to private directories; use Apache with AllowOverride enabled and confirm it blocks database and logs URLs. Do not expose this development installation to the public internet. For production use HTTPS, a restricted DB account, credentials outside the web root, rate limiting, and backups.

See `docs/DATABASE.md` for relations and `docs/TEST_CASES.md` for testing. PHP lint and limited unauthenticated HTTP checks were executed in the build environment, but no live MySQL/PDO MySQL driver was available there. Run the listed integration tests on XAMPP and record actual outcomes; do not submit unchecked tests as passing.

## Demo grading policy

Exams 40%, quizzes/activities 20%, projects 25%, attendance 10%, participation/others 5%. These are example weights, not verified HCDC grading policy. Each component is a normalized percentage (0–100), not a raw point total. Enter 0 only when the actual category grade is zero. The five inputs are required; the server uses exact integer arithmetic and rounds the weighted average to two decimals. JavaScript previews the same calculation. The existing `grades.score` stores the final result, and legacy rows retain their original score with NULL component fields. Changing the policy in the future requires a versioning/recalculation plan. The enrollment catalog has no official curriculum eligibility mapping; staff must verify subject choices manually.

See `docs/V2_TEST_CASES.md` for new test cases and actual automated-check scope.
