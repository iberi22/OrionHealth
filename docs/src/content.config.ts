import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const blog = defineCollection({
	loader: glob({ pattern: "**/*.md", base: "./src/content/blog" }),
	schema: z.object({
		title: z.string(),
		description: z.string(),
		pubDate: z.coerce.date(),
		updatedDate: z.coerce.date().optional(),
		heroImage: z.string().optional(),
		author: z.string().default('OrionHealth Team'),
		tags: z.array(z.string()).optional(),
	}),
});

const features = defineCollection({
	loader: glob({ pattern: "**/*.md", base: "./src/content/features" }),
	schema: z.object({
		title: z.string(),
		req_id: z.string(),
		status: z.enum(['implemented', 'partial', 'planned']),
	}),
});

export const collections = { blog, features };
