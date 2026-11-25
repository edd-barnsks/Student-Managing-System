# Student Manager — WS101 edition

A framework-free PHP 8.1+ / HTML / CSS / vanilla JavaScript and MySQL (or XAMPP MariaDB) conversion of the supplied ADV_104 project. It retains the dark dashboard, student records, classes, courses and grades, with separate student and staff authentication. Add your team members here before submission.

## XAMPP setup (Windows)

1. Extract the ZIP. Copy the `Student-Manager-WS101` folder into `D:\XAMPP\htdocs` (or your own XAMPP `htdocs`). Keep the original application and database as backups.
2. Start Apache and MySQL in XAMPP. If Herd is occupying Apache's port, stop Herd's web server or configure Apache to use a different port.
3. Open `http://localhost/phpmyadmin` and use Import to import `database/student_management_ws101.sql` **once**. This creates a separate database named `student_management_ws101`, not the original `student_management`. If the database already exists with tables, do not rerun the import; use a new empty database or back it up first. If using a limited DB account, have an administrator create the database first and import the schema with the database selected.
4. Open `config/database.php`. The defaults are `127.0.0.1`, port `3306`, database `student_management_ws101`, user `root`, empty password. Update these to your local settings. Make sure PHP's `pdo_mysql` extension is enabled (normally included in XAMPP).
5. Visit `http://localhost/Student-Manager-ADV104/`. If Apache uses another port, add it to the URL. No npm, Composer, Laravel, or PowerShell is required.

### Local demo credentials

Select the appropriate account type in the login form.

| Role | Username | Password |
|---|---|---|
| Administrator | admin | AdminDemo!2026 |
| Teacher | teacher | TeacherDemo!2026 |
| Student | student | StudentDemo!2026 |

These are local demonstration credentials only. Change them using My account before any shared deployment. The demo teacher teaches DEMO101, and the demo student is enrolled in that class. The demo student has an initial grade of 90. Use the teacher account to change it, then sign in as the student to verify.

## Features and permissions

- Administrator: CRUD students, courses, classes and staff; assign teachers to classes, enroll students, issue student activation codes, reset or disable student accounts, view all grades, export grades CSV, view audit history.
- Teacher: view only assigned classes and their enrolled students; add, edit and delete grades for those enrollments. No account management. A grade is one score (0–100) per enrollment, as in the source project; no term/semester model added.
- Student: view own profile, enrolled classes and grades only; change own password. No grade writing.
- Administrator can view all grades but cannot write grades, honoring the explicit teacher-only rule. Administrators can assign teachers and manage accounts; a teacher can enter a grade only for an enrolled student in a class assigned to that teacher.
- Registration is controlled: admin opens Student accounts, issues a 24-hour one-time code for a specific student, shares it privately, then student selects Activate student account on the login page. Staff creation is administrator-only.
- A record with dependent enrollments, grades or assigned classes cannot be deleted until those dependencies are handled. Disable staff instead of deleting historical grade authors.

## Source migration decisions

The RAR includes `student_management-2.sql`. It already contained a single students table with a gender enum; male/female were not separate physical tables. The new UI has one student list. All three original student records and both grades are retained, including the student record named Admin (not treated as a staff account). The empty courses table is populated from the original course names. The old classes row is ADV1021 with teacher text Faith, but both grades reference ADV102. The new schema preserves ADV1021 and introduces an unassigned ADV102 placeholder with both original grades connected by student ID. Confirm the course-code mapping and teacher identity with your team, then assign the actual teacher via Classes. The original user table did not contain roles or student IDs and included one plaintext password; those accounts were not migrated or granted permissions. Issue new activation codes or create staff accounts after verifying identity. Existing user passwords are not copied. Demo records are separately labeled.

## Security and course requirements

`config/database.php` central PDO connection; `includes/functions.php` reusable parameterized helpers, validation, escaping, error logging; `includes/auth.php` password verification, role checks, session handling; `index.php` route authorization and CSRF; `pages/` HTML GET/POST forms, role-specific queries and CRUD; `database/` SQL export with sample data; `logs/error.log` technical error logging (created on error); `pages/export.php` CSV file handling; `docs/TEST_CASES.md` local verification checklist. Passwords use password_hash/password_verify. Sessions regenerate on login and invalidate on password changes. Username-only remember cookie. All data queries use prepared PDO statements, user content is HTML escaped. `.htaccess` denies direct web access to private directories; use Apache with AllowOverride enabled and confirm it blocks database and logs URLs. Do not expose this development installation to the public internet. For production use HTTPS, a restricted DB account, credentials outside the web root, rate limiting, and backups.

See `docs/DATABASE.md` for relations and `docs/TEST_CASES.md` for testing. PHP lint and limited unauthenticated HTTP checks were executed in the build environment, but no live MySQL/PDO MySQL driver was available there. Run the listed integration tests on XAMPP and record actual outcomes; do not submit unchecked tests as passing.
