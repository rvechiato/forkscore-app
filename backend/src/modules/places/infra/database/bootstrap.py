from datetime import UTC, datetime
from uuid import NAMESPACE_DNS, uuid5

from sqlalchemy import inspect, text
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session

from src.modules.places.infra.database.models import CategoryModel, SubcategoryModel

_PLACE_TAXONOMY: dict[str, list[str]] = {
    "Restaurante": [
        "Fine Dining",
        "Casual Dining",
        "Self-Service",
        "Temático",
    ],
    "Lanchonete": [
        "Fast Food",
        "Hamburgueria",
        "Sanduíches",
        "Salgados",
    ],
    "Cafeteria": [
        "Cafeteria",
        "Doceria",
        "Confeitaria",
        "Padaria Gourmet",
    ],
    "Bar": [
        "Bar Tradicional",
        "Gastrobar",
        "Pub",
        "Bar com Música",
    ],
    "Especializado": [
        "Japonês",
        "Italiano",
        "Churrascaria",
        "Vegano",
        "Árabe",
        "Mexicano",
        "Indiano",
        "Outros",
    ],
    "Street Food": [
        "Food Truck",
        "Barraca",
        "Feira Gastronômica",
        "Mercado Gastronômico",
    ],
    "Experiência": [
        "Sensorial",
        "Chef's Table",
        "Panorâmico",
        "Imersivo",
    ],
}

_LEGACY_CATEGORY_NAME = "Especializado"
_LEGACY_SUBCATEGORY_NAME = "Outros"


def ensure_places_schema(engine: Engine, database_url: str) -> None:
    """Apply lightweight legacy SQLite schema changes for the places module."""

    if not database_url.startswith("sqlite"):
        return

    inspector = inspect(engine)
    if "places" not in inspector.get_table_names():
        return

    columns = {column["name"] for column in inspector.get_columns("places")}
    statements: list[str] = []
    if "category_id" not in columns:
        statements.append(
            "ALTER TABLE places ADD COLUMN category_id VARCHAR(36) NULL",
        )
    if "subcategory_id" not in columns:
        statements.append(
            "ALTER TABLE places ADD COLUMN subcategory_id VARCHAR(36) NULL",
        )
    if "instagram_url" not in columns:
        statements.append(
            "ALTER TABLE places ADD COLUMN instagram_url VARCHAR(255) NULL",
        )

    if not statements:
        return

    with engine.begin() as connection:
        for statement in statements:
            connection.execute(text(statement))


def seed_places_taxonomy(session: Session) -> None:
    """Seed the default gastronomic taxonomy if it is absent."""

    now = datetime.now(UTC)
    existing_categories = {
        category.slug: category
        for category in session.query(CategoryModel).all()
    }
    existing_subcategories = {
        (subcategory.category_id, subcategory.slug): subcategory
        for subcategory in session.query(SubcategoryModel).all()
    }

    for category_name, subcategory_names in _PLACE_TAXONOMY.items():
        category_slug = _slugify(category_name)
        category_id = str(uuid5(NAMESPACE_DNS, f"forkscore-category:{category_slug}"))
        category_model = existing_categories.get(category_slug)

        if category_model is None:
            category_model = CategoryModel(
                id=category_id,
                name=category_name,
                slug=category_slug,
                is_active=True,
                created_at=now,
                updated_at=now,
            )
            session.add(category_model)
            existing_categories[category_slug] = category_model
        else:
            category_model.name = category_name
            category_model.is_active = True
            category_model.updated_at = now

        for subcategory_name in subcategory_names:
            subcategory_slug = _slugify(subcategory_name)
            subcategory_id = str(
                uuid5(
                    NAMESPACE_DNS,
                    f"forkscore-subcategory:{category_slug}:{subcategory_slug}",
                ),
            )
            key = (category_model.id, subcategory_slug)
            subcategory_model = existing_subcategories.get(key)
            if subcategory_model is None:
                subcategory_model = SubcategoryModel(
                    id=subcategory_id,
                    category_id=category_model.id,
                    name=subcategory_name,
                    slug=subcategory_slug,
                    is_active=True,
                    created_at=now,
                    updated_at=now,
                )
                session.add(subcategory_model)
                existing_subcategories[key] = subcategory_model
            else:
                subcategory_model.name = subcategory_name
                subcategory_model.is_active = True
                subcategory_model.updated_at = now

    session.commit()
    _backfill_existing_places(session)


def _backfill_existing_places(session: Session) -> None:
    legacy_category_slug = _slugify(_LEGACY_CATEGORY_NAME)
    legacy_subcategory_slug = _slugify(_LEGACY_SUBCATEGORY_NAME)
    legacy_category = (
        session.query(CategoryModel)
        .filter(CategoryModel.slug == legacy_category_slug)
        .one()
    )
    legacy_subcategory = (
        session.query(SubcategoryModel)
        .filter(
            SubcategoryModel.category_id == legacy_category.id,
            SubcategoryModel.slug == legacy_subcategory_slug,
        )
        .one()
    )

    session.execute(
        text(
            """
            UPDATE places
            SET category_id = :category_id
            WHERE category_id IS NULL
            """,
        ),
        {"category_id": legacy_category.id},
    )
    session.execute(
        text(
            """
            UPDATE places
            SET subcategory_id = :subcategory_id
            WHERE subcategory_id IS NULL
            """,
        ),
        {"subcategory_id": legacy_subcategory.id},
    )
    session.commit()


def taxonomy_id(kind: str, *parts: str) -> str:
    """Build deterministic ids for taxonomy records."""

    return str(uuid5(NAMESPACE_DNS, f"forkscore-{kind}:{':'.join(parts)}"))


def slugify_taxonomy(value: str) -> str:
    """Expose slug generation for tests and fixtures."""

    return _slugify(value)


def _slugify(value: str) -> str:
    replacements = {
        "á": "a",
        "à": "a",
        "ã": "a",
        "â": "a",
        "é": "e",
        "ê": "e",
        "í": "i",
        "ó": "o",
        "ô": "o",
        "õ": "o",
        "ú": "u",
        "ç": "c",
        "'": "",
    }
    result = value.strip().lower()
    for source, target in replacements.items():
        result = result.replace(source, target)
    return "-".join(result.replace("/", " ").split())
