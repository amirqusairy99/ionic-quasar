-- TalentForge Database Schema and Seed Data
-- Freelance Job Marketplace

CREATE DATABASE IF NOT EXISTS talentforge;
USE talentforge;

-- ============================================
-- SCHEMA
-- ============================================

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    bio TEXT,
    skills VARCHAR(500),
    avatar_url VARCHAR(500) DEFAULT '/img/default-avatar.png',
    location VARCHAR(100),
    hourly_rate DECIMAL(10,2) DEFAULT 0.00,
    reset_token VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100),
    budget_min DECIMAL(10,2),
    budget_max DECIMAL(10,2),
    job_type ENUM('fixed', 'hourly') DEFAULT 'fixed',
    experience_level ENUM('entry', 'intermediate', 'expert') DEFAULT 'intermediate',
    status ENUM('open', 'in_progress', 'completed', 'cancelled') DEFAULT 'open',
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    user_id INT NOT NULL,
    cover_letter TEXT,
    proposed_rate DECIMAL(10,2),
    status ENUM('pending', 'accepted', 'rejected', 'withdrawn') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE threads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    participant_one INT NOT NULL,
    participant_two INT NOT NULL,
    last_message_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_one) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (participant_two) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    thread_id INT NOT NULL,
    sender_id INT NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (thread_id) REFERENCES threads(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reviewer_id INT NOT NULL,
    reviewee_id INT NOT NULL,
    job_id INT,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    body TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE SET NULL
);

CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    balance DECIMAL(12,2) DEFAULT 0.00,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE payment_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    type ENUM('deposit', 'withdrawal', 'coupon', 'payment') NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE coupons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- SEED DATA
-- ============================================

-- Passwords are all bcrypt hashes of the plaintext shown in comments
-- admin123 => $2a$10$8K1p/a0dL1LXMw6gJPxKnOYkN1r5r5r5r5r5r5r5r5r5r5r5r5r5r
-- password123 => same hash pattern

-- Using pre-computed bcrypt hashes for "admin123" and "password123"
INSERT INTO users (name, email, password, role, bio, skills, avatar_url, location, hourly_rate) VALUES
('Admin', 'admin@talentforge.com', '$2a$10$mvfPsYQuGm0iYlWmvU1ahOtMeAQSUKX4cKMa9mU8xOegrs2CE3fOa', 'admin', 'Platform administrator and community manager at TalentForge. Ensuring quality and trust across the marketplace.', 'Platform Management, Community Moderation', 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin', 'San Francisco, CA', 150.00),
('John Mitchell', 'john@example.com', '$2a$10$/ymK/ZaPENaGMCajYFPeI.hyYsiUG5Uut78m5gqcy/IzDUp0/G3uu', 'user', 'Full-stack developer with 8 years of experience building scalable web applications. Specializing in React, Node.js, and cloud architecture. Previously worked at startups and Fortune 500 companies.', 'JavaScript, React, Node.js, AWS, PostgreSQL, Docker', 'https://api.dicebear.com/7.x/avataaars/svg?seed=john', 'New York, NY', 95.00),
('Jane Cooper', 'jane@example.com', '$2a$10$/ymK/ZaPENaGMCajYFPeI.hyYsiUG5Uut78m5gqcy/IzDUp0/G3uu', 'user', 'Senior UI/UX designer passionate about creating intuitive digital experiences. I bring ideas to life through research-driven design and pixel-perfect implementation.', 'UI/UX Design, Figma, Adobe XD, Prototyping, User Research', 'https://api.dicebear.com/7.x/avataaars/svg?seed=jane', 'Los Angeles, CA', 85.00),
('Marcus Rivera', 'marcus@example.com', '$2a$10$/ymK/ZaPENaGMCajYFPeI.hyYsiUG5Uut78m5gqcy/IzDUp0/G3uu', 'user', 'DevOps engineer and cloud architect. I help companies build resilient infrastructure and CI/CD pipelines. AWS Certified Solutions Architect.', 'AWS, Kubernetes, Terraform, CI/CD, Linux, Python', 'https://api.dicebear.com/7.x/avataaars/svg?seed=marcus', 'Austin, TX', 120.00),
('Sarah Chen', 'sarah@example.com', '$2a$10$/ymK/ZaPENaGMCajYFPeI.hyYsiUG5Uut78m5gqcy/IzDUp0/G3uu', 'user', 'Data scientist and ML engineer with a PhD in Computer Science. I transform raw data into actionable insights and build production ML pipelines.', 'Python, TensorFlow, PyTorch, SQL, Spark, Data Visualization', 'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah', 'Seattle, WA', 130.00),
('David Park', 'david@example.com', '$2a$10$/ymK/ZaPENaGMCajYFPeI.hyYsiUG5Uut78m5gqcy/IzDUp0/G3uu', 'user', 'Mobile app developer specializing in cross-platform solutions. Built and shipped 20+ apps on iOS and Android with millions of downloads combined.', 'React Native, Flutter, Swift, Kotlin, Firebase', 'https://api.dicebear.com/7.x/avataaars/svg?seed=david', 'Chicago, IL', 100.00),
('Emily Watson', 'emily@example.com', '$2a$10$/ymK/ZaPENaGMCajYFPeI.hyYsiUG5Uut78m5gqcy/IzDUp0/G3uu', 'user', 'Technical writer and content strategist with experience at major tech companies. I create clear, engaging documentation and developer guides.', 'Technical Writing, API Documentation, Markdown, Content Strategy', 'https://api.dicebear.com/7.x/avataaars/svg?seed=emily', 'Portland, OR', 65.00),
('Alex Nguyen', 'alex@example.com', '$2a$10$/ymK/ZaPENaGMCajYFPeI.hyYsiUG5Uut78m5gqcy/IzDUp0/G3uu', 'user', 'Blockchain developer and smart contract auditor. Building the decentralized future with Solidity and Rust. Open source contributor and Web3 advocate.', 'Solidity, Rust, Ethereum, Web3.js, Smart Contracts', 'https://api.dicebear.com/7.x/avataaars/svg?seed=alex', 'Miami, FL', 140.00),
('Rachel Thompson', 'rachel@example.com', '$2a$10$/ymK/ZaPENaGMCajYFPeI.hyYsiUG5Uut78m5gqcy/IzDUp0/G3uu', 'user', 'Digital marketing specialist with expertise in SEO, SEM, and social media growth. I have helped businesses increase their organic traffic by 300% on average.', 'SEO, Google Ads, Social Media, Analytics, Content Marketing', 'https://api.dicebear.com/7.x/avataaars/svg?seed=rachel', 'Denver, CO', 75.00),
('Carlos Mendez', 'carlos@example.com', '$2a$10$/ymK/ZaPENaGMCajYFPeI.hyYsiUG5Uut78m5gqcy/IzDUp0/G3uu', 'user', 'Cybersecurity consultant and penetration tester. OSCP and CEH certified. I help organizations identify and fix security vulnerabilities before attackers do.', 'Penetration Testing, Network Security, Python, Linux, SIEM', 'https://api.dicebear.com/7.x/avataaars/svg?seed=carlos', 'Washington, DC', 145.00);

-- Jobs (20 jobs posted by various users)
INSERT INTO jobs (title, description, category, budget_min, budget_max, job_type, experience_level, status, user_id) VALUES
('Build a Modern E-commerce Platform', 'We need a senior developer to build a full-featured e-commerce platform with <b>React</b> frontend and <b>Node.js</b> backend. The platform should include product catalog, shopping cart, checkout with Stripe integration, order management, and an admin dashboard.\n\nKey Requirements:\n- Responsive design for mobile and desktop\n- User authentication and authorization\n- Product search and filtering\n- Payment processing with Stripe\n- Order tracking and email notifications\n- Admin panel for inventory management', 'Web Development', 5000.00, 12000.00, 'fixed', 'expert', 'open', 2),
('Mobile App UI/UX Redesign', 'Looking for a talented designer to completely redesign our fitness tracking mobile app. The current design feels outdated and we want a modern, engaging experience that keeps users coming back.\n\nDeliverables:\n- User research and competitive analysis\n- Wireframes for all screens\n- High-fidelity mockups in Figma\n- Interactive prototype\n- Design system documentation', 'Design', 3000.00, 6000.00, 'fixed', 'intermediate', 'open', 4),
('AWS Infrastructure Migration', 'Migrate our on-premise infrastructure to AWS. We have approximately 15 servers running various services including web applications, databases, and cron jobs. Need someone experienced with AWS migration strategies.\n\nScope:\n- Assessment of current infrastructure\n- Migration plan and timeline\n- Set up VPC, EC2, RDS, S3\n- Configure auto-scaling and load balancing\n- Set up monitoring with CloudWatch\n- Documentation and knowledge transfer', 'DevOps', 8000.00, 15000.00, 'fixed', 'expert', 'open', 2),
('Machine Learning Model for Customer Churn', 'Develop a machine learning model to predict customer churn for our SaaS product. We have 3 years of customer data including usage patterns, support tickets, and billing history.\n\nRequirements:\n- Data exploration and feature engineering\n- Model selection and training (try at least 3 algorithms)\n- Model evaluation and optimization\n- API endpoint for real-time predictions\n- Documentation and model explanation', 'Data Science', 4000.00, 8000.00, 'fixed', 'expert', 'open', 6),
('React Native Fitness App Development', 'Build a cross-platform fitness app that works on both iOS and Android. The app should integrate with health APIs and wearable devices.\n\nFeatures needed:\n- Workout tracking and logging\n- Exercise library with animations\n- Progress charts and statistics\n- Social features (follow friends, share workouts)\n- Integration with Apple Health and Google Fit\n- Push notifications for reminders', 'Mobile Development', 6000.00, 10000.00, 'fixed', 'intermediate', 'open', 3),
('Technical Documentation for REST API', 'Write comprehensive documentation for our REST API (approximately 45 endpoints). Documentation should be developer-friendly and include code examples in multiple languages.\n\nScope:\n- API reference documentation\n- Getting started guide\n- Authentication guide\n- Code examples in Python, JavaScript, and cURL\n- Error handling documentation\n- Changelog format', 'Technical Writing', 1500.00, 3000.00, 'fixed', 'intermediate', 'open', 4),
('Smart Contract Development for NFT Marketplace', 'Develop and audit smart contracts for an NFT marketplace on Ethereum. The marketplace should support minting, listing, buying, and auctioning NFTs.\n\nRequirements:\n- ERC-721 and ERC-1155 support\n- Marketplace contract with listing/buying/auctioning\n- Royalty distribution system\n- Gas optimization\n- Comprehensive test suite\n- Security audit documentation', 'Blockchain', 10000.00, 20000.00, 'fixed', 'expert', 'open', 8),
('SEO Audit and Optimization Strategy', 'Conduct a comprehensive SEO audit of our website and develop an optimization strategy. We are an e-commerce company with about 500 product pages.\n\nDeliverables:\n- Technical SEO audit report\n- Keyword research and mapping\n- On-page optimization recommendations\n- Content strategy for link building\n- Monthly reporting template\n- Implementation roadmap', 'Digital Marketing', 2000.00, 4000.00, 'fixed', 'intermediate', 'open', 9),
('Kubernetes Cluster Setup and Configuration', 'Set up a production-grade Kubernetes cluster on GKE for our microservices architecture. We have 12 microservices that need to be containerized and orchestrated.\n\nScope:\n- Cluster architecture design\n- Deployment manifests for all services\n- Service mesh with Istio\n- CI/CD pipeline integration\n- Monitoring with Prometheus and Grafana\n- Disaster recovery plan', 'DevOps', 7000.00, 12000.00, 'hourly', 'expert', 'open', 2),
('Penetration Testing for FinTech Application', 'Perform a comprehensive penetration test on our financial technology web application and mobile APIs. We need someone with experience in financial application security.\n\nScope:\n- Web application penetration testing\n- API security testing\n- Mobile app security assessment\n- Authentication and authorization testing\n- Report with findings and remediation steps\n- Re-test after fixes', 'Security', 5000.00, 9000.00, 'fixed', 'expert', 'open', 10),
('WordPress to Headless CMS Migration', 'Migrate our WordPress blog (800+ posts) to a headless CMS architecture using Strapi and Next.js frontend.\n\nRequirements:\n- Content migration with SEO preservation\n- Custom Next.js frontend with SSG/ISR\n- Strapi CMS setup and customization\n- Image optimization pipeline\n- Search functionality\n- RSS feed and sitemap generation', 'Web Development', 4000.00, 7000.00, 'fixed', 'intermediate', 'open', 3),
('Data Pipeline with Apache Airflow', 'Design and implement a data pipeline using Apache Airflow to process and transform data from multiple sources including APIs, databases, and CSV files.\n\nScope:\n- Airflow DAG development\n- Data extraction from 5+ sources\n- Data transformation and validation\n- Load into BigQuery data warehouse\n- Error handling and alerting\n- Documentation and runbooks', 'Data Engineering', 5000.00, 9000.00, 'hourly', 'expert', 'in_progress', 5),
('Brand Identity Design for Tech Startup', 'Create a complete brand identity package for our AI-powered productivity startup.\n\nDeliverables:\n- Logo design (primary, secondary, favicon)\n- Color palette and typography system\n- Brand guidelines document\n- Business card and letterhead design\n- Social media templates\n- Presentation template', 'Design', 2500.00, 5000.00, 'fixed', 'intermediate', 'open', 6),
('Python Backend for Real-time Chat Application', 'Build a scalable real-time chat backend using Python, FastAPI, and WebSockets. The system should support direct messages, group chats, and file sharing.\n\nRequirements:\n- WebSocket-based real-time messaging\n- User presence and typing indicators\n- Message history and search\n- File upload and sharing\n- Rate limiting and spam prevention\n- Horizontal scaling support', 'Backend Development', 4000.00, 8000.00, 'fixed', 'expert', 'open', 2),
('iOS App Performance Optimization', 'Our iOS app is experiencing performance issues including slow launch times, memory leaks, and UI jank. We need an expert to diagnose and fix these issues.\n\nScope:\n- Performance profiling with Instruments\n- Memory leak detection and fixes\n- Launch time optimization\n- UI rendering optimization\n- Network layer optimization\n- Performance monitoring setup', 'Mobile Development', 3000.00, 5000.00, 'hourly', 'expert', 'open', 7),
('Content Marketing Strategy for B2B SaaS', 'Develop a comprehensive content marketing strategy for our B2B SaaS product in the HR tech space.\n\nDeliverables:\n- Content audit and gap analysis\n- Buyer persona development\n- Content calendar (6 months)\n- SEO keyword strategy\n- Distribution channel plan\n- 5 sample blog posts\n- Performance KPIs and tracking', 'Digital Marketing', 3000.00, 5000.00, 'fixed', 'intermediate', 'open', 9),
('GraphQL API Development', 'Design and implement a GraphQL API to replace our existing REST API. The API serves a project management tool with complex data relationships.\n\nRequirements:\n- Schema design for 15+ types\n- Queries, mutations, and subscriptions\n- Authentication and authorization\n- N+1 query optimization with DataLoader\n- Rate limiting and query complexity analysis\n- API documentation with GraphQL Playground', 'Backend Development', 5000.00, 9000.00, 'fixed', 'expert', 'open', 5),
('Automated Testing Suite for E-commerce', 'Build a comprehensive automated testing suite for our e-commerce platform covering unit tests, integration tests, and E2E tests.\n\nScope:\n- Unit tests with Jest (target 80% coverage)\n- Integration tests for API endpoints\n- E2E tests with Cypress\n- Performance tests with k6\n- CI/CD integration\n- Test documentation and best practices guide', 'QA Engineering', 3500.00, 6000.00, 'fixed', 'intermediate', 'open', 2),
('Flutter App for Restaurant Ordering', 'Build a restaurant ordering app with Flutter that supports dine-in ordering via QR codes, takeout, and delivery.\n\nFeatures:\n- QR code menu scanning\n- Cart and checkout\n- Payment integration (Stripe)\n- Order tracking\n- Restaurant admin panel\n- Push notifications\n- Multi-language support', 'Mobile Development', 8000.00, 14000.00, 'fixed', 'intermediate', 'open', 6),
('Security Compliance Audit (SOC 2)', 'Help us achieve SOC 2 Type II compliance for our cloud-based SaaS platform. We need guidance on security controls, policy development, and audit preparation.\n\nScope:\n- Gap assessment against SOC 2 criteria\n- Security policy development\n- Control implementation guidance\n- Evidence collection framework\n- Employee security training materials\n- Audit preparation and support', 'Security', 8000.00, 15000.00, 'fixed', 'expert', 'open', 10);

-- Applications (40 applications)
INSERT INTO applications (job_id, user_id, cover_letter, proposed_rate, status) VALUES
(1, 3, 'I have extensive experience building e-commerce platforms and would love to bring my expertise to this project. My recent work includes a marketplace that processes $2M+ in monthly transactions.', 10000.00, 'pending'),
(1, 5, 'As a full-stack developer with experience in both React and Node.js, I can deliver a high-quality e-commerce solution. I have built similar platforms for 3 previous clients.', 9500.00, 'pending'),
(1, 8, 'I specialize in building scalable web applications and have worked on multiple e-commerce projects. I can also integrate Web3 payment options if desired.', 11000.00, 'rejected'),
(2, 3, 'UI/UX design is my passion. I have redesigned apps for companies like Nike and Spotify, resulting in 40%+ engagement increases. I would love to transform your fitness app.', 5000.00, 'accepted'),
(2, 7, 'I bring a unique perspective combining technical writing with design. I can ensure your app has both beautiful design and clear, intuitive user flows.', 4500.00, 'pending'),
(3, 4, 'AWS infrastructure is my specialty. I am an AWS Certified Solutions Architect with 6 years of migration experience. I have migrated 50+ companies to the cloud.', 12000.00, 'accepted'),
(3, 10, 'I can handle the migration with a security-first approach, ensuring your infrastructure is not only functional but also hardened against common attack vectors.', 13000.00, 'pending'),
(4, 5, 'With my PhD in ML and 5 years of industry experience, I can build a highly accurate churn prediction model. I have done similar work for subscription-based businesses.', 7000.00, 'accepted'),
(4, 2, 'I have strong data science skills and have built prediction models for customer lifecycle analysis. Happy to share my portfolio of similar projects.', 6000.00, 'pending'),
(5, 6, 'I have built and published 20+ mobile apps including 3 fitness apps. I am very familiar with health API integrations on both iOS and Android platforms.', 8500.00, 'pending'),
(5, 2, 'React Native is my primary technology. I can deliver a polished cross-platform app with smooth animations and reliable health API integration.', 9000.00, 'pending'),
(6, 7, 'Technical documentation is my forte. I have written API docs for companies like Twilio and Stripe. I focus on creating developer-friendly content that reduces support tickets.', 2500.00, 'accepted'),
(6, 9, 'I combine my marketing writing skills with technical knowledge to create documentation that is both accurate and easy to follow. Available to start immediately.', 2000.00, 'pending'),
(7, 8, 'Smart contract development is my specialty. I have audited contracts holding $50M+ in value and developed marketplace contracts for 3 NFT platforms.', 18000.00, 'pending'),
(7, 10, 'I can develop secure smart contracts and perform a thorough security audit. My approach combines automated testing with manual code review.', 16000.00, 'pending'),
(8, 9, 'I have helped 30+ e-commerce companies improve their organic traffic. My average client sees a 200% increase in organic traffic within 6 months.', 3500.00, 'accepted'),
(8, 7, 'I can provide both the SEO audit and create optimized content. My dual expertise in writing and SEO makes me uniquely qualified for this project.', 3000.00, 'pending'),
(9, 4, 'Kubernetes is at the core of my DevOps practice. I have set up production clusters for companies processing millions of requests per day.', 110.00, 'pending'),
(9, 10, 'I can set up a secure, scalable Kubernetes cluster and implement comprehensive monitoring. Security is always my top priority in infrastructure work.', 125.00, 'pending'),
(10, 10, 'As an OSCP-certified pentester specializing in financial applications, I am uniquely qualified for this engagement. I have tested applications for banks and fintech startups.', 8000.00, 'pending'),
(10, 4, 'I can provide a thorough security assessment covering all OWASP Top 10 vulnerabilities plus financial-specific attack vectors.', 7500.00, 'pending'),
(11, 2, 'I have migrated several WordPress sites to headless CMS architectures. I understand the importance of preserving SEO rankings during migration.', 6000.00, 'pending'),
(11, 3, 'I can deliver a beautiful, performant Next.js frontend along with a well-configured Strapi backend. I have done similar migrations for content-heavy sites.', 5500.00, 'accepted'),
(12, 5, 'Data pipeline engineering is a significant part of my work. I have built production Airflow pipelines processing terabytes of data daily.', 130.00, 'accepted'),
(13, 3, 'Brand identity design is where I started my career. I love creating visual systems that tell a compelling story. Check out my portfolio for similar work.', 4000.00, 'pending'),
(14, 2, 'I have built several real-time applications using WebSockets. I can deliver a scalable, production-ready chat backend with all the features you need.', 7000.00, 'pending'),
(14, 6, 'Real-time communication systems are my specialty. I have worked on chat systems used by millions of users and understand the scaling challenges involved.', 6500.00, 'pending'),
(15, 6, 'iOS performance optimization is an area I am passionate about. I have successfully reduced launch times by 60% and eliminated memory leaks for multiple apps.', 120.00, 'pending'),
(16, 9, 'B2B SaaS content marketing is my primary focus. I have developed strategies that generated 500+ qualified leads per month for similar companies.', 4500.00, 'pending'),
(16, 7, 'I can create compelling content that resonates with HR professionals. My work combines industry knowledge with SEO best practices.', 4000.00, 'pending'),
(17, 2, 'I have designed and implemented several GraphQL APIs including one that serves 10M+ queries per day. I focus on performance and developer experience.', 8000.00, 'pending'),
(17, 5, 'I bring both backend engineering and data expertise to GraphQL development. I can optimize your schema for complex queries while keeping response times low.', 7500.00, 'pending'),
(18, 2, 'I have extensive experience with Jest, Cypress, and performance testing. I can build a testing suite that gives your team confidence in every deployment.', 5000.00, 'pending'),
(18, 4, 'Quality engineering is crucial for e-commerce. I can set up a comprehensive testing pipeline integrated with your CI/CD system.', 5500.00, 'pending'),
(19, 6, 'I love building Flutter apps and have shipped restaurant ordering apps before. I can deliver a polished product with all the features you need.', 12000.00, 'pending'),
(19, 2, 'I can build a beautiful, functional restaurant app with Flutter. My experience with payment integrations and real-time features makes me a great fit.', 11000.00, 'pending'),
(20, 10, 'SOC 2 compliance is a core part of my security consulting practice. I have helped 10+ companies achieve SOC 2 Type II certification.', 12000.00, 'pending'),
(20, 4, 'I have experience implementing SOC 2 controls in cloud environments. I can help with both the technical controls and the policy documentation.', 11000.00, 'pending'),
(1, 6, 'I have built e-commerce platforms that handle high traffic with ease. My expertise in mobile development also means the platform will work beautifully on all devices.', 10500.00, 'pending'),
(3, 5, 'While my primary expertise is in data science, I have significant experience with cloud infrastructure. I can bring a unique analytical perspective to the migration planning.', 11000.00, 'pending');

-- Threads and Messages
INSERT INTO threads (participant_one, participant_two, last_message_at) VALUES
(2, 3, '2024-01-15 14:30:00'),
(2, 4, '2024-01-16 09:15:00'),
(3, 5, '2024-01-14 16:45:00'),
(6, 7, '2024-01-15 11:20:00'),
(8, 9, '2024-01-13 13:00:00'),
(2, 10, '2024-01-16 10:30:00');

INSERT INTO messages (thread_id, sender_id, content, is_read, created_at) VALUES
(1, 2, 'Hi Jane! I saw your application for the e-commerce project. Your portfolio looks impressive. Can we discuss the timeline?', TRUE, '2024-01-15 10:00:00'),
(1, 3, 'Hi John! Thank you for reaching out. I am available to start next week. For a project of this scope, I estimate 8-10 weeks for full delivery. Would that work for your timeline?', TRUE, '2024-01-15 10:30:00'),
(1, 2, 'That works perfectly. Let me share the detailed requirements document with you. Also, do you have experience with Stripe Connect for marketplace payments?', TRUE, '2024-01-15 11:00:00'),
(1, 3, 'Yes, I have implemented Stripe Connect in two previous marketplace projects. I can set up split payments, vendor onboarding, and automated payouts. I will review the requirements and send you a detailed proposal by tomorrow.', TRUE, '2024-01-15 14:30:00'),
(2, 4, 'Marcus, your AWS migration proposal is exactly what we need. When can we schedule a kickoff call?', TRUE, '2024-01-16 08:00:00'),
(2, 2, 'Great to hear! I am free this Thursday or Friday afternoon. I will prepare a preliminary assessment based on what you have shared so far.', TRUE, '2024-01-16 08:30:00'),
(2, 4, 'Thursday at 2 PM works. I will send you a calendar invite. Looking forward to it!', TRUE, '2024-01-16 09:15:00'),
(3, 5, 'Sarah, I saw you got accepted for the data pipeline project. Congratulations! I wanted to ask about your experience with Airflow — any tips for someone just getting started?', TRUE, '2024-01-14 15:00:00'),
(3, 3, 'Thank you! For getting started with Airflow, I recommend beginning with simple DAGs and gradually adding complexity. The official docs have a great tutorial. Happy to hop on a call if you want to chat more about it.', TRUE, '2024-01-14 16:45:00'),
(4, 7, 'Emily, your documentation samples are really well-structured. Are you interested in collaborating on a developer portal project?', FALSE, '2024-01-15 10:00:00'),
(4, 6, 'Thanks David! I would love to discuss. What technology stack is the developer portal using?', FALSE, '2024-01-15 11:20:00'),
(5, 9, 'Alex, I have a client interested in launching an NFT collection. Would you be available for a consultation?', TRUE, '2024-01-13 12:00:00'),
(5, 8, 'Sure, Rachel! I would be happy to help. Tell me more about the collection size and which blockchain they are targeting.', TRUE, '2024-01-13 13:00:00'),
(6, 10, 'Carlos, we need a follow-up security assessment after implementing the fixes from your last report. Are you available next month?', FALSE, '2024-01-16 10:00:00'),
(6, 2, 'Absolutely. I will block out the second week of February. Please share the remediation summary so I can prepare the re-test scope.', FALSE, '2024-01-16 10:30:00');

-- Reviews
INSERT INTO reviews (reviewer_id, reviewee_id, job_id, rating, body, created_at) VALUES
(2, 3, 2, 5, 'Jane delivered exceptional design work for our fitness app redesign. Her attention to detail and user research insights were invaluable. The app engagement increased by 45% after implementing her designs. Highly recommend!', '2024-01-10 12:00:00'),
(4, 2, 3, 5, 'John managed the AWS migration flawlessly. Zero downtime during cutover, excellent documentation, and the new infrastructure reduced our hosting costs by 30%. Will definitely work with him again.', '2024-01-08 15:00:00'),
(2, 5, 4, 5, 'Sarah built an incredibly accurate churn prediction model. Her feature engineering was creative, and the model is now integrated into our daily workflows. Communication throughout the project was excellent.', '2024-01-12 09:00:00'),
(3, 7, 6, 4, 'Emily wrote clear, comprehensive API documentation that our developers actually enjoy reading. She asked great questions to understand the nuances of our API. Only wish we had more time for additional code examples.', '2024-01-11 14:00:00'),
(6, 9, 8, 5, 'Rachel transformed our SEO strategy. Within 3 months, our organic traffic doubled. Her keyword research was thorough and her content recommendations were spot-on. A true professional.', '2024-01-09 11:00:00'),
(5, 4, 12, 5, 'Marcus set up a rock-solid Kubernetes cluster for our services. His monitoring setup with Prometheus and Grafana has saved us from several potential outages. Extremely knowledgeable and responsive.', '2024-01-07 16:00:00'),
(9, 10, 10, 5, 'Carlos found critical vulnerabilities in our financial app that we had completely missed. His reports are detailed, actionable, and clearly prioritized. Our app is significantly more secure thanks to his work.', '2024-01-06 10:00:00'),
(7, 3, 11, 4, 'Jane delivered a beautiful Next.js frontend for our headless CMS migration. The site is fast and SEO-friendly. Minor delays on the Strapi customization, but the end result exceeded expectations.', '2024-01-05 13:00:00'),
(8, 2, 1, 5, 'John built a fantastic e-commerce platform for us. The code is clean, well-documented, and the Stripe integration works flawlessly. He went above and beyond with performance optimization.', '2023-12-20 09:00:00'),
(3, 6, 5, 4, 'David built a great fitness app with React Native. The health API integrations work well on both platforms. The app is smooth and the code quality is excellent. Would work with again.', '2023-12-15 14:00:00');

-- Payment accounts
INSERT INTO payments (user_id, balance) VALUES
(1, 0.00),
(2, 15750.00),
(3, 12300.00),
(4, 8900.00),
(5, 21000.00),
(6, 6500.00),
(7, 4200.00),
(8, 18500.00),
(9, 7800.00),
(10, 16400.00);

-- Payment transaction history
INSERT INTO payment_transactions (user_id, amount, type, description, created_at) VALUES
(2, 10000.00, 'payment', 'Payment for E-commerce Platform project', '2023-12-25 10:00:00'),
(2, 5000.00, 'payment', 'Payment for AWS Migration project', '2024-01-10 10:00:00'),
(2, 750.00, 'deposit', 'Bonus payment from client', '2024-01-12 10:00:00'),
(3, 5000.00, 'payment', 'Payment for Fitness App Redesign', '2024-01-10 10:00:00'),
(3, 5500.00, 'payment', 'Payment for WordPress Migration', '2024-01-08 10:00:00'),
(3, 1800.00, 'payment', 'Payment for Brand Identity project', '2024-01-05 10:00:00'),
(4, 12000.00, 'payment', 'Payment for AWS Infrastructure Migration', '2024-01-15 10:00:00'),
(4, -3100.00, 'withdrawal', 'Withdrawal to bank account', '2024-01-16 10:00:00'),
(5, 7000.00, 'payment', 'Payment for ML Churn Model', '2024-01-12 10:00:00'),
(5, 9000.00, 'payment', 'Payment for Data Pipeline project', '2024-01-14 10:00:00'),
(5, 5000.00, 'payment', 'Payment for GraphQL API', '2024-01-13 10:00:00');

-- Coupons
INSERT INTO coupons (code, discount_amount, is_active) VALUES
('SAVE20', 20.00, TRUE),
('WELCOME50', 50.00, TRUE),
('SUMMER2024', 30.00, FALSE);
