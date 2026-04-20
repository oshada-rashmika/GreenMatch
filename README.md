# 🧠 GreenMatch | Supervisor–Project Matching System

## 🚀 Overview
**GreenMatch** is a full-stack academic project allocation platform designed to eliminate bias and inefficiencies in assigning supervisors to final-year student projects. 

Traditional allocation methods are often manual, inconsistent, and influenced by subjective bias. GreenMatch replaces this with a **blind matching system**, automated workflows, and role-based dashboards to streamline the entire lifecycle — from proposal submission to evaluation.

---

## 🎯 Problem
Academic institutions face major issues in project allocation:
- Manual or semi-manual assignment processes.
- Bias based on student identity rather than merit.
- Poor alignment between supervisor expertise and project topics.
- Lack of structured communication and tracking.
- Inefficient handling of meetings, evaluations, and deadlines.

---

## 💡 Solution
GreenMatch introduces a **blind, system-driven matching workflow**:
1. Students submit project proposals tagged with technologies and domains.
2. The system anonymizes submissions before supervisors review them.
3. Supervisors evaluate purely based on **technical merit and relevance**.
4. A **swipe-based interface** allows supervisors to quickly select projects.
5. Once interest is confirmed → identity is revealed → collaboration begins.

---

## ✨ Key Features

### 🕶 Blind Matching System
- Removes student identity during evaluation.
- Prevents unconscious bias.
- Ensures merit-based selection.

### 🔄 Automated Identity Reveal
- Triggered when a supervisor confirms interest.
- Secure exchange of contact details.
- Seamless transition into collaboration.

### 🧑‍💻 Role-Based Dashboards (RBAC)

**👨‍🎓 Student**
- Submit and manage project proposals.
- Track milestones and deadlines.
- View project status updates.

**👨‍🏫 Supervisor**
- Filter projects by expertise (tags).
- Swipe-based selection interface (Tinder-like).
- Manage assigned groups and meetings.

**🧑‍💼 Module Leader**
- Manage academic modules.
- Control timelines (matching, reviews, viva).
- Oversee the full allocation lifecycle.

### 🔥 Advanced Workflow Features
- **📅 Anti-Ghosting Meeting Scheduler**: Tracks meeting activity and flags inactive sessions using scheduled background jobs.
- **✅ Milestone Engine**: Time-based unlocking of features (matching, evaluation, etc.) that enforces structured academic timelines.
- **💬 Real-Time Chat System**: Student ↔ Supervisor communication integrated directly within dashboards.
- **🧮 Evaluation Canvas**: JSON-based scoring system for structured marking of projects.

---

## 🛠 Tech Stack

### Frontend
- **Flutter (Dart)** — Cross-platform (iOS, Android, Web)
- **State Management:** Provider
- **Routing:** `go_router`
- **UI/UX:** `flutter_card_swiper` (swipe interface), `flutter_animate` (animations), Google Fonts
- **Storage & Networking:** `http` (API calls), `flutter_secure_storage` (JWT storage), `shared_preferences`

### Backend
- **NestJS (Node.js, TypeScript)** — Modular architecture
- **Database:** PostgreSQL
- **ORM:** Prisma (type-safe queries + migrations)

### Security
- JWT Authentication
- bcrypt password hashing
- Role-Based Access Control (RBAC)
- Passport.js integration

### Dev Practices
- Monorepo architecture
- Git with feature branching
- Conventional Commits

---

## 🧠 System Architecture

### High-Level Flow
1. **Students submit proposals with:**
   - Description
   - Tech stack tags
   - Domain (AI, Web, etc.)
2. **Backend sanitizes data:**
   - Removes identifying fields.
   - Sends anonymized payloads to supervisors.
3. **Supervisors:**
   - Browse via swipe interface.
   - Match based on interest + expertise.
4. **Match confirmed:**
   - System triggers **identity reveal**.
   - Collaboration begins.

---

## 📂 Project Structure

```text
GreenMatch/
├── backend/
│   ├── prisma/
│   │   ├── schema.prisma
│   │   └── seed.ts
│   └── src/
│       ├── app.module.ts
│       ├── main.ts
│       └── modules/
│           ├── auth/
│           ├── projects/
│           ├── tags/
│           ├── supervisors/
│           ├── evaluations/
│           └── meetings/
│
└── frontend/
    ├── lib/
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   ├── widgets/
    │   └── theme/
    └── android/ ios/ web/
```
---

## ⚙️ Setup & Installation

### Prerequisites
* Node.js
* Flutter SDK
* PostgreSQL

### 1. Clone Repository
```bash
git clone https://github.com/oshada-rashmika/GreenMatch/](https://github.com/oshada-rashmika/GreenMatch/
cd greenmatch
```

### 2. Backend Setup
```bash
cd backend
npm install
```

#### Configure .env:
```bash
DATABASE_URL=postgresql://user:password@localhost:5432/greenmatch
JWT_SECRET=your_secret
```

#### Run migrations:
```bash
npx prisma migrate dev
```

#### Start server:
```bash
npm run start:dev
```

### 3. Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
```

## 🔥 Unique / Complex Parts

### 🧬 Multi-Actor Database Design
- Complex relationships:
  - Students ↔ Groups ↔ Projects
  - Supervisors ↔ Modules ↔ Tags

- Uses composite keys and join tables:
  - `GroupMember`
  - `ProjectTag`
  - `SupervisorTag`

---

### ⏱ Milestone Engine
- Features unlock based on timeline:
  - Matching phase
  - Evaluation phase
  - Viva phase

---

### 👉 Swipe-Based Matching UI
- Replaces manual selection
- Reduces admin overhead
- Improves supervisor engagement

---

## ⚠️ Challenges Faced
- Maintaining strict anonymity during matching
- Designing scalable multi-role RBAC system
- Handling complex relational database schema
- Synchronizing real-time features (chat + meetings)
- Ensuring timeline-driven feature control

---

## 🔮 Future Improvements
- AI-based recommendation system for better matching
- Advanced analytics dashboard for module leaders
- Notification system (email + push)
- Improved real-time chat (WebSockets optimization)
- Mobile-first UX refinements

---

## 📌 Key Takeaways
- Built a full-stack system with real-world complexity
- Solved a genuine institutional problem
- Implemented bias-free matching logic
- Designed scalable architecture with clean separation of concerns

---

## 👨‍💻 Author
**Velovs & Co**
