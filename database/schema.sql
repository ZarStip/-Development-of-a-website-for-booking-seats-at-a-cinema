CREATE TABLE users (
    id            SERIAL PRIMARY KEY,
    login         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email         VARCHAR(100) NOT NULL,
    phone         VARCHAR(100) NOT NULL UNIQUE,
    last_name     VARCHAR(100) NOT NULL,
    first_name    VARCHAR(100) NOT NULL,
    middle_name   VARCHAR(100)
);
CREATE UNIQUE INDEX ux_users_email_lower ON users (LOWER(email));
CREATE TABLE clients (
    id      SERIAL PRIMARY KEY,
    user_id INT NOT NULL UNIQUE REFERENCES users (id)
);
CREATE TABLE employees (
    id        SERIAL PRIMARY KEY,
    user_id   INT NOT NULL UNIQUE REFERENCES users (id),
    job_title VARCHAR(100) NOT NULL CHECK (job_title IN ('Администратор', 'Менеджер', 'Продавец'))
);
CREATE TABLE halls (
    id            SERIAL PRIMARY KEY,
    hall_number   INT NOT NULL UNIQUE,
    layout_config VARCHAR(255) NOT NULL
);
CREATE TABLE show_formats (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE CHECK (name IN ('2D', '3D', 'IMAX'))
);
CREATE TABLE seat_types (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE CHECK (name IN ('обычный', 'VIP', 'диван')),
    coefficient NUMERIC(3,2) NOT NULL CHECK (coefficient > 0)
);
CREATE TABLE hall_show_formats (
    hall_id        INT NOT NULL REFERENCES halls (id) ON DELETE CASCADE,
    show_format_id INT NOT NULL REFERENCES show_formats (id) ON DELETE CASCADE,
    PRIMARY KEY (hall_id, show_format_id)
);
CREATE TABLE seats (
    id           SERIAL PRIMARY KEY,
    hall_id      INT NOT NULL REFERENCES halls (id) ON DELETE CASCADE,
    seat_type_id INT NOT NULL REFERENCES seat_types (id),
    row_num      INT NOT NULL,
    seat_num     INT NOT NULL,
    UNIQUE (hall_id, row_num, seat_num)
);
CREATE TABLE films (
    id            SERIAL PRIMARY KEY,
    title         VARCHAR(100) NOT NULL,
    description   TEXT NOT NULL,
    critic_rating NUMERIC(3,1) NOT NULL CHECK (critic_rating BETWEEN 0 AND 10),
    review_rating NUMERIC(3,1) NOT NULL DEFAULT 0 CHECK (review_rating BETWEEN 0 AND 10),
    age_limit     VARCHAR(100) NOT NULL CHECK (age_limit IN ('0+', '6+', '12+', '16+', '18+')),
    trailer_url   VARCHAR(255) NOT NULL,
    duration_min  INT NOT NULL CHECK (duration_min > 0),
    release_year  INT NOT NULL CHECK (release_year BETWEEN 1888 AND 2100),
    banner_url    VARCHAR(255) NOT NULL
);
CREATE TABLE genres (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE directors (
    id          SERIAL PRIMARY KEY,
    last_name   VARCHAR(100) NOT NULL,
    first_name  VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    description TEXT NOT NULL
);
CREATE TABLE actors (
    id          SERIAL PRIMARY KEY,
    last_name   VARCHAR(100) NOT NULL,
    first_name  VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    description TEXT NOT NULL
);
CREATE TABLE film_genres (
    genre_id INT NOT NULL REFERENCES genres (id) ON DELETE CASCADE,
    film_id  INT NOT NULL REFERENCES films (id) ON DELETE CASCADE,
    PRIMARY KEY (genre_id, film_id)
);
CREATE TABLE film_actors (
    actor_id  INT NOT NULL REFERENCES actors (id) ON DELETE CASCADE,
    film_id   INT NOT NULL REFERENCES films (id) ON DELETE CASCADE,
    role_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (actor_id, film_id)
);
CREATE TABLE film_directors (
    director_id INT NOT NULL REFERENCES directors (id) ON DELETE CASCADE,
    film_id     INT NOT NULL REFERENCES films (id) ON DELETE CASCADE,
    PRIMARY KEY (director_id, film_id)
);
CREATE TABLE screenings (
    id             SERIAL PRIMARY KEY,
    film_id        INT NOT NULL REFERENCES films (id),
    hall_id        INT NOT NULL,
    show_format_id INT NOT NULL,
    start_time     TIMESTAMP NOT NULL,
    end_time       TIMESTAMP NOT NULL,
    price          INT NOT NULL CHECK (price >= 0),
    CHECK (end_time > start_time),
    FOREIGN KEY (hall_id, show_format_id) REFERENCES hall_show_formats (hall_id, show_format_id)
);
CREATE TABLE orders (
    id                 SERIAL PRIMARY KEY,
    client_id          INT NOT NULL REFERENCES clients (id),
    booking_expires_at TIMESTAMP,
    created_at         TIMESTAMP NOT NULL,
    total_amount       INT NOT NULL CHECK (total_amount >= 0),
    status             VARCHAR(100) NOT NULL CHECK (status IN ('забронировано', 'оплачено', 'отменен'))
);
CREATE TABLE tickets (
    id           SERIAL PRIMARY KEY,
    order_id     INT NOT NULL REFERENCES orders (id),
    screening_id INT NOT NULL REFERENCES screenings (id),
    seat_id      INT NOT NULL REFERENCES seats (id),
    status       VARCHAR(100) NOT NULL CHECK (status IN ('забронировано', 'оплачено', 'возвращен', 'отменен')),
    price        INT NOT NULL CHECK (price >= 0)
);
CREATE UNIQUE INDEX ux_tickets_active_seat ON tickets (screening_id, seat_id) WHERE status IN ('забронировано', 'оплачено');
CREATE TABLE reviews (
    id          SERIAL PRIMARY KEY,
    film_id     INT NOT NULL REFERENCES films (id) ON DELETE CASCADE,
    client_id   INT NOT NULL REFERENCES clients (id),
    rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 10),
    created_at  TIMESTAMP NOT NULL,
    review_text TEXT,
    UNIQUE (client_id, film_id)
);
CREATE TABLE review_replies (
    id         SERIAL PRIMARY KEY,
    review_id  INT NOT NULL REFERENCES reviews (id) ON DELETE CASCADE,
    client_id  INT NOT NULL REFERENCES clients (id),
    created_at TIMESTAMP NOT NULL,
    reply_text TEXT NOT NULL
);
CREATE TABLE review_reactions (
    review_id     INT NOT NULL REFERENCES reviews (id) ON DELETE CASCADE,
    client_id     INT NOT NULL REFERENCES clients (id),
    reaction_type VARCHAR(100) NOT NULL
                  CHECK (reaction_type IN ('нравится', 'не нравится')),
    PRIMARY KEY (review_id, client_id)
);
CREATE TABLE reply_reactions (
    reply_id      INT NOT NULL REFERENCES review_replies (id) ON DELETE CASCADE,
    client_id     INT NOT NULL REFERENCES clients (id),
    reaction_type VARCHAR(100) NOT NULL CHECK (reaction_type IN ('нравится', 'не нравится')),
    PRIMARY KEY (reply_id, client_id)
);