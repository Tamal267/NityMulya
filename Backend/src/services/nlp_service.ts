/**
 * NLP Service Integration
 * Connects to Python NLP microservice for AI-enhanced complaint analysis
 */

import axios, { AxiosInstance } from "axios";

interface ComplaintAnalysisRequest {
  complaint_text: string;
  customer_name?: string;
  shop_name?: string;
  product_name?: string;
}

interface ValidityResult {
  validity_score: number;
  is_valid: boolean;
  is_gibberish?: boolean;
  reasons: string[];
  confidence: string;
}

interface PriorityResult {
  priority_score: number;
  priority_level: string;
  reasons: string[];
  confidence: string;
}

interface SeverityResult {
  severity_score: number;
  severity_level: string;
  reasons: string[];
  confidence: string;
}

interface SentimentResult {
  sentiment_score: number;
  sentiment: string;
  emotion_intensity: string;
  reasons: string[];
}

interface CategoryResult {
  category: string;
  confidence: string;
  matched_keywords: number;
  all_categories?: Record<string, number>;
}

interface ComplaintAnalysisResult {
  validity: ValidityResult;
  priority: PriorityResult;
  severity: SeverityResult;
  sentiment: SentimentResult;
  category: CategoryResult;
  summary: string;
  language: string;
  metadata: {
    word_count: number;
    char_count: number;
    has_numbers: boolean;
    is_gibberish?: boolean;
  };
  original_text?: string;
  cleaned_text?: string;
}

interface AnalysisResponse {
  success: boolean;
  analysis: ComplaintAnalysisResult;
  processed_at: string;
  processing_time_ms: number;
}

class NLPService {
  private client: AxiosInstance;
  private isAvailable: boolean = false;

  constructor() {
    const baseURL = process.env.NLP_SERVICE_URL || "http://localhost:8001";
    const apiKey = process.env.NLP_API_KEY || "your-secret-api-key";

    this.client = axios.create({
      baseURL,
      headers: {
        "X-API-Key": apiKey,
        "Content-Type": "application/json",
      },
      timeout: 30000, // 30 seconds
    });

    // Check if service is available
    this.checkHealth();
  }

  /**
   * Check if NLP service is healthy
   */
  async checkHealth(): Promise<boolean> {
    try {
      const response = await this.client.get("/health");
      this.isAvailable = response.data.status === "healthy";
      return this.isAvailable;
    } catch (error) {
      console.error("NLP Service is not available:", error);
      this.isAvailable = false;
      return false;
    }
  }

  /**
   * Analyze a single complaint
   */
  async analyzeComplaint(
    request: ComplaintAnalysisRequest
  ): Promise<ComplaintAnalysisResult | null> {
    try {
      if (!this.isAvailable) {
        await this.checkHealth();
        if (!this.isAvailable) {
          console.warn("NLP Service is not available. Skipping AI analysis.");
          return null;
        }
      }

      const response = await this.client.post<AnalysisResponse>(
        "/api/analyze-complaint",
        request
      );

      if (response.data.success) {
        console.log(
          `✅ AI analysis completed in ${response.data.processing_time_ms}ms`
        );
        return response.data.analysis;
      }

      return null;
    } catch (error: any) {
      console.error("Error analyzing complaint:", error.message);

      // If service is down, mark as unavailable
      if (error.code === "ECONNREFUSED" || error.response?.status === 503) {
        this.isAvailable = false;
      }

      return null;
    }
  }

  /**
   * Batch analyze multiple complaints
   */
  async batchAnalyze(
    complaints: ComplaintAnalysisRequest[]
  ): Promise<ComplaintAnalysisResult[]> {
    try {
      if (!this.isAvailable) {
        await this.checkHealth();
        if (!this.isAvailable) {
          console.warn(
            "NLP Service is not available. Skipping batch analysis."
          );
          return [];
        }
      }

      const response = await this.client.post("/api/batch-analyze", complaints);

      if (response.data.success) {
        console.log(
          `✅ Batch analyzed ${response.data.total_complaints} complaints`
        );
        return response.data.results;
      }

      return [];
    } catch (error: any) {
      console.error("Error in batch analysis:", error.message);
      return [];
    }
  }

  /**
   * Get model information
   */
  async getModelInfo(): Promise<any> {
    try {
      const response = await this.client.get("/api/model-info");
      return response.data;
    } catch (error) {
      console.error("Error getting model info:", error);
      return null;
    }
  }

  /**
   * Test text preprocessing
   */
  async testPreprocessing(text: string): Promise<any> {
    try {
      const response = await this.client.post("/api/test-preprocessing", null, {
        params: { text },
      });
      return response.data;
    } catch (error) {
      console.error("Error testing preprocessing:", error);
      return null;
    }
  }

  /**
   * Check if NLP service is currently available
   */
  isServiceAvailable(): boolean {
    return this.isAvailable;
  }
}

// Export singleton instance
export const nlpService = new NLPService();

// Export types
export type {
  ComplaintAnalysisResult,
  ValidityResult,
  PriorityResult,
  SeverityResult,
  SentimentResult,
  CategoryResult,
  ComplaintAnalysisRequest,
  AnalysisResponse,
};
// Export types
export type {
  ComplaintAnalysisRequest,
  ComplaintAnalysisResult,
  ValidityResult,
  PriorityResult,
  SentimentResult,
  CategoryResult,
};
