#include <stdint.h>
#include <stdio.h>
#include <glib-object.h>

// gcc -O0 $(pkg-config --cflags glib-2.0) filename $(pkg-config --libs glib-2.0 gobject-2.0)
typedef struct _Object
{
  GObject parent_instance;

  gdouble value;
} Object;
typedef struct _ObjectClass
{
  GObjectClass parent_class;
} ObjectClass;
enum
{
  PROP_SOURCE_0,

  PROP_SOURCE_VALUE,
};
static GType object_get_type (void);
G_DEFINE_TYPE (Object, object, G_TYPE_OBJECT)
static void
object_set_property (GObject      *gobject,
                             guint         prop_id,
                             const GValue *value,
                             GParamSpec   *pspec)
{
  Object *source = (Object *) gobject;

  switch (prop_id)
    {
    case PROP_SOURCE_VALUE:
      source->value = g_value_get_double (value);
      break;

    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (gobject, prop_id, pspec);
    }
}
static void
object_get_property (GObject    *gobject,
                             guint       prop_id,
                             GValue     *value,
                             GParamSpec *pspec)
{
  Object *source = (Object *) gobject;

  switch (prop_id)
    {
    case PROP_SOURCE_VALUE:
      g_value_set_double (value, source->value);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (gobject, prop_id, pspec);
    }
}

static void
object_class_init (ObjectClass *klass)
{
  GObjectClass *gobject_class = G_OBJECT_CLASS (klass);
  gobject_class->set_property = object_set_property;
  gobject_class->get_property = object_get_property;
  g_object_class_install_property (gobject_class, PROP_SOURCE_VALUE,
                                   g_param_spec_double ("value", "Value", "Value",
                                                        0.0, 10.0,
                                                        1.0,
                                                        G_PARAM_READWRITE));
}
static void
object_init (Object *self)
{
}

int main() {

	float x = 0.50000;
	double d = static_cast<double>(x);
	// 0.500000 0.5 0.500000
	printf("%f %g %f\n", x, d, static_cast<float>(d));

	float x1 = 0.500000;
	double d1 = 0;
	Object *source = (Object*) g_object_new (object_get_type (), NULL);
	g_object_set (source, "value", static_cast<double>(x1), NULL);
	g_object_get (source, "value", &d1, NULL);
	// returned 0.5
	printf("%f %g %f\n", x1, static_cast<double>(x1), static_cast<float>(d1));

	return 0;
}
