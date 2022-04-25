import Rails from "@rails/ujs";

interface Params {
  file: File,
  sessionEndpoint: string,
  sessionEndpointMethod: string,
}

export interface SessionCredentials {
  access_key_id: string;
  secret_access_key: string;
  session_token?: string;
}

export interface SessionData {
  id: string,
  signed_url: string,
}

export default class SponsorshipAssetFileUploader {
  public file: File;
  public sessionEndpoint: string;
  public sessionEndpointMethod: string;
  public fileId?: string;

  private session?: SessionData;
  private signedUrl?: string;

  constructor(params: Params) {
    this.file = params.file;
    this.sessionEndpoint = params.sessionEndpoint;
    this.sessionEndpointMethod = params.sessionEndpointMethod;
  }

  public async getSession() {
    if (this.session) return this.session;

    const sessionPayload = new FormData();
    sessionPayload.append('extension', this.file.name.split('.').pop() || '');
    sessionPayload.append(Rails.csrfParam() || '', Rails.csrfToken() || '');
    const sessionResp = await fetch(this.sessionEndpoint, {method: this.sessionEndpointMethod, credentials: 'include', body: sessionPayload});
    if (sessionResp.ok) {
      const session: SessionData = await sessionResp.json();
      this.session = session;
      this.fileId = this.session.id;
      this.signedUrl = session.signed_url;
      return this.session;
    } else {
      throw `Uploader getSession failed: status=${sessionResp.status}`;
    }
  }

  public async perform() {
    await this.getSession();

    if (!this.signedUrl) {
      return null;
    }

    await fetch(this.signedUrl, {
      method: "PUT",
      body: this.file,
    });
  }
}
